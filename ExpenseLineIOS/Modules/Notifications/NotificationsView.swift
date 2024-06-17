//
//  NotificationView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 08.06.24.
//

import SwiftUI

enum NotificationAction {
    
    case enable
    case delete
    
}

struct NotificationCard: View {
    
    @EnvironmentObject var notificationService: NotificationService
    @Binding var notification: NotificationEntity
    @Binding var selectedNotification: NotificationEntity?
    @State var isEnabled: Bool
    
    private var updateNotification: (NotificationAction, NotificationEntity) -> Void
    
    init(notification: Binding<NotificationEntity>,
         selectedNotification: Binding<NotificationEntity?>,
         updateNotification: @escaping (NotificationAction, NotificationEntity) -> Void) {
        self._notification = notification
        self._selectedNotification = selectedNotification
        self.isEnabled = notification.wrappedValue.enabled
        self.updateNotification = updateNotification
    }
    
    var body: some View {
        FlexibleCardView {
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading) {
                        if let category = notification.category {
                            HStack {
                                IconView(name: category.iconNameValue, color: category.colorValue, size: 25)
                                Text(category.nameValue)
                                    .font(.caption)
                                Spacer()
                            }
                        }
                        Text(notification.nameValue)
                    }
                    Spacer()
                    Menu {
                        Button {
                            selectedNotification = notification
                        } label: {
                            Text("Edit")
                        }
                        Button(role: .destructive) {
                            updateNotification(.delete, notification)
                        } label: {
                            Text("Delete")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color("FrDefault"))
                    }
                }
                HStack {
                    switch notification.typeValue {
                    case .nonotification:
                        NoNotificationHeaderView()
                    case .exact:
                        OneTimeNotificationHeaderView()
                    case .daily:
                        DailyNotificationHeaderView()
                    case .weekly:
                        WeeklyNotificationHeaderView()
                    }
                }
            }
        }
        .onChange(of: notification.enabled) { value in
            isEnabled = value
        }
    }
    
    @ViewBuilder
    func NoNotificationHeaderView() -> some View {
        HStack {
            Image(systemName: "bell.slash")
            Text("No Signal")
            Spacer()
        }
        .font(.caption)
    }
    
    @ViewBuilder
    func DailyNotificationHeaderView() -> some View {
        Toggle(isOn: $isEnabled) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "bell")
                    Text("Daily")
                }
                if let date = notification.date {
                    Text(formatTime(date))
                }
            }
            .font(.caption)
        }
        .onChange(of: isEnabled) { value in
            notification.enabled = value
            updateNotification(.enable, notification)
        }
        .tint(Color("FrDefault"))
    }
    
    @ViewBuilder
    func OneTimeNotificationHeaderView() -> some View {
        Toggle(isOn: $isEnabled) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "bell")
                    Text("One Time")
                }
                if let date = notification.date {
                    Text(formatDate(date))
                }
            }
            .font(.caption)
        }
        .onChange(of: isEnabled) { value in
            notification.enabled = value
            updateNotification(.enable, notification)
        }
        .tint(Color("FrDefault"))
    }
    
    @ViewBuilder
    func WeeklyNotificationHeaderView() -> some View {
        Toggle(isOn: $isEnabled) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "bell")
                    Text("Weekly")
                }
                HStack {
                    ForEach(notificationService.getWeekDays()) { day in
                        Text(day.shortName)
                            .foregroundStyle(
                                notification.weekDaysArr.contains(day.id)
                                ? Color("FrDefault")
                                : .black
                            )
                            .underline(notification.weekDaysArr.contains(day.id))
                    }
                }
            }
            .font(.caption)
        }
        .onChange(of: isEnabled) { value in
            notification.enabled = value
            updateNotification(.enable, notification)
        }
        .tint(Color("FrDefault"))
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.setLocalizedDateFormatFromTemplate("MM-dd-yyyy HH:mm")
        
        return dateFormatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        
        return dateFormatter.string(from: date)
    }
    
}


struct NotificationsView: View {
    
    @EnvironmentObject var notificationService: NotificationService
    
    @StateObject var vm: NotificationsViewModel
    @State var showEditNotificationSheet: Bool = false
    @State var selectedNotification: NotificationEntity? = nil
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack {
                    ForEach($vm.notifications) { $notification in
                        NotificationCard(
                            notification: $notification,
                            selectedNotification: $selectedNotification
                        ) { action, notification in
                            DispatchQueue.main.async {
                                switch action {
                                case .enable:
                                    vm.resheduleNotification(notification)
                                case .delete:
                                    vm.deleteNotification(notification)
                                }
                                vm.loadNotifications()
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity)
            }
            AddExpenseButton {
                showEditNotificationSheet.toggle()
            }
            .offset(x: -20, y: -20)
        }
        .background(Color("BgDefault"))
        .onAppear {
            vm.loadNotifications()
        }
        .sheet(isPresented: $showEditNotificationSheet, onDismiss: onNotificationUpdated) {
            EditNotificationSheetView(
                vm: EditNotificationSheetViewModel(notification: vm.newNotification(),
                                                   notificationService: notificationService))
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
        .sheet(item: $selectedNotification, onDismiss: onNotificationUpdated) { notification in
            EditNotificationSheetView(
                vm: EditNotificationSheetViewModel(notification: notification,
                                                   notificationService: notificationService))
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
    }
    
    func onNotificationUpdated() {
        vm.loadNotifications()
    }
    
}


#Preview("Notifications") {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    let category = bundle.budgetService.newCategoryEntity(budget)
    category.typeValue = .outcomeFixed
    category.name = "Preview Category"
    category.iconName = "fi-insurance"
    category.colorValue = .indigo
    
    let notification1 = bundle.notificationService.newNotificationEntity(budget)
    notification1.name = "Preview 1"
    notification1.enabled = true
    notification1.typeValue = .nonotification
    
    let notification2 = bundle.notificationService.newNotificationEntity(budget)
    notification2.name = "Preview 2"
    notification2.enabled = true
    notification2.typeValue = .daily
    notification2.date = Date()
    
    let notification3 = bundle.notificationService.newNotificationEntity(budget)
    notification3.name = "Preview 3"
    notification3.typeValue = .exact
    notification3.date = Date()
    
    let notification4 = bundle.notificationService.newNotificationEntity(budget)
    notification4.name = "Preview 4"
    notification4.typeValue = .weekly
    notification4.weekDaysArr = [1, 3, 6]
    notification4.category = category
    
    let vm = NotificationsViewModel(
        categoryRef: CategoryNotificationsRef(category: nil),
        budget: budget,
        budgetService: bundle.budgetService,
        notificationService: bundle.notificationService
    )
    try! bundle.notificationService.save()
    
    return NotificationsView(vm: vm)
        .serviceBundle(bundle)
}

#Preview("No notifications") {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    
    let vm = NotificationsViewModel(
        categoryRef: CategoryNotificationsRef(category: nil),
        budget: budget,
        budgetService: bundle.budgetService,
        notificationService: bundle.notificationService
    )
    
    return NotificationsView(vm: vm)
        .serviceBundle(bundle)
}
