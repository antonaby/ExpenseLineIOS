//
//  NotificationView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 08.06.24.
//

import SwiftUI

struct NotificationCard: View {
    
    @EnvironmentObject var formatters: FormattersHolder
    @EnvironmentObject var notificationService: NotificationService
    @Binding var notification: NotificationEntity
        
    var body: some View {
        FlexibleCardView {
            NavigationLink(value: notification) {
                VStack {
                    HStack(alignment: .firstTextBaseline) {
                        Text(notification.nameValue)
                            .bold()
                        Spacer()
                        if let category = notification.category {
                            HStack {
                                Text(category.nameValue)
                                    .font(.caption)
                                IconView(name: category.iconNameValue, size: 25)
                                    .accessibilityLabel(category.nameValue)
                            }
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
        }
    }
    
    @ViewBuilder
    func NoNotificationHeaderView() -> some View {
        HStack {
            Image(systemName: "bell.slash")
                .foregroundColor(Color.appLink)
            Text("No Signal")
            Spacer()
        }
        .font(.caption)
    }
    
    @ViewBuilder
    func DailyNotificationHeaderView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: notification.enabled ? "bell" : "bell.slash")
                    .foregroundColor(Color.appLink)
                Text("Daily")
            }
            if let date = notification.date {
                Text(formatters.formatHour(date))
            }
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    func OneTimeNotificationHeaderView() -> some View {
        if let date = notification.date {
            if date > Date() {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: notification.enabled ? "bell" : "bell.slash")
                            .foregroundColor(Color.appLink)
                        Text("One Time")
                    }
                    Text(formatters.formatDate(date))
                }
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "bell.slash")
                            .foregroundColor(Color.appLink)
                        Text("One Time")
                        Spacer()
                    }
                    Text(formatters.formatDate(date))
                        .foregroundStyle(Color.appDestructiveLink)
                }
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    @ViewBuilder
    func WeeklyNotificationHeaderView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: notification.enabled ? "bell" : "bell.slash")
                    .foregroundColor(Color.appLink)
                Text("Weekly")
            }
            HStack {
                if let date = notification.date {
                    Text(formatters.formatHour(date))
                }
                ForEach(notificationService.getWeekDays()) { day in
                    Text(day.shortName)
                        .foregroundStyle(
                            notification.weekDaysArr.contains(day.id)
                            ? Color.appLink
                            : Color.appCardTextColor
                        )
                        .underline(notification.weekDaysArr.contains(day.id))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.caption)
    }
    
}


struct NotificationsView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var subscriptionLimitService: SubscriptionLimitService
    @EnvironmentObject var notificationService: NotificationService
    
    @StateObject var vm: NotificationsViewModel
    @State var showEditNotificationSheet: Bool = false
    @State var selectedNotification: NotificationEntity? = nil
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                ForEach($vm.notifications) { $notification in
                    NotificationCard(notification: $notification)
                        .defaultListCard()
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                vm.deleteNotification(notification)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(Color.appDestructiveLink)
                            Button {
                                selectedNotification = notification
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(Color.appLink)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            if showEnableNotification(notification) {
                                Button {
                                    notification.enabled.toggle()
                                    vm.resheduleNotification(notification)
                                } label: {
                                    if notification.enabled {
                                        Label("Turn off", systemImage: "bell.slash")
                                    } else {
                                        Label("Turn on", systemImage: "bell")
                                    }
                                }
                                .tint(Color.appLink)
                            }
                        }
                }
                Color.clear
                    .background(Color.appBackground)
                    .frame(height: 70)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .listStyle(.insetGrouped)
            .listRowSpacing(10)
            VStack {
                HStack {
                    Button {
                        vm.todayNotifications = true
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Today")
                                .lineLimit(1)
                        }
                        .frame(width: 100)
                        .font(.caption)
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(vm.todayNotifications ? Color.appButtonTextColor : Color.appButtonTextColorInactive)
                    .tint(vm.todayNotifications ? Color.appLink : Color.appBackgroundSecondary)
                    Button {
                        vm.todayNotifications = false
                    } label: {
                        HStack {
                            Image(systemName: "bell")
                            Text("Reminders")
                                .lineLimit(1)
                        }
                        .frame(width: 100)
                        .font(.caption)
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(!vm.todayNotifications ? Color.appButtonTextColor : Color.appButtonTextColorInactive)
                    .tint(!vm.todayNotifications ? Color.appLink : Color.appBackgroundSecondary)
                    HelpButton {
                        appState.showHelpPage(for: .notificationPage)
                    }
                }
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
            AddExpenseButton {
                if subscriptionManager.hasProSubscription()
                    || subscriptionLimitService.checkMaxNotificationCount(budget: vm.budget) {
                    showEditNotificationSheet.toggle()
                } else {
                    subscriptionManager.showPaywall()
                }
            }
            .offset(x: -20, y: -20)
            .accessibilityLabel("Create a reminder")
            .accessibilityElement(children: .combine)
        }
        .onAppear {
            UICollectionView.appearance().contentInset.top = 10
            vm.loadNotifications()
            appState.showHelpPage(for: .notificationPage, firstTime: true)
        }
        .onDisappear {
            vm.cancelAll()
        }
        .sheet(isPresented: $showEditNotificationSheet, onDismiss: onNotificationUpdated) {
            EditNotificationSheetView(
                vm: EditNotificationSheetViewModel(notification: vm.newNotification(),
                                                   notificationService: notificationService))
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .preferredColorScheme(appState.colorScheme)
        }
        .sheet(item: $selectedNotification, onDismiss: onNotificationUpdated) { notification in
            EditNotificationSheetView(
                vm: EditNotificationSheetViewModel(notification: notification,
                                                   notificationService: notificationService))
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .preferredColorScheme(appState.colorScheme)
        }
    }
    
    func onNotificationUpdated() {
        vm.loadNotifications()
    }
    
    func showEnableNotification(_ notification: NotificationEntity) -> Bool {
        if let date = notification.date, notification.typeValue != .nonotification {
            if notification.typeValue == .exact && date < Date() {
                return false
            }
            
            return true
        }
        
        return false
    }
    
}


#Preview("Notifications") {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    let category = bundle.budgetService.newCategoryEntity(budget)
    category.typeValue = .outcomeFixed
    category.name = "Preview Category"
    category.iconName = "fi-insurance"
    
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
    notification3.date = Date().plusHour(1)
    
    let notification4 = bundle.notificationService.newNotificationEntity(budget)
    notification4.name = "Preview 4"
    notification4.typeValue = .weekly
    notification4.weekDaysArr = [1, 3, 6]
    notification4.category = category
    notification4.date = Date()
    
    let notification5 = bundle.notificationService.newNotificationEntity(budget)
    notification5.name = "Preview 5"
    notification5.typeValue = .exact
    notification5.date = Date().plusHour(-1)
    
    let vm = NotificationsViewModel(
        categoryRef: CategoryNotificationsRef(category: nil),
        budget: budget,
        budgetService: bundle.budgetService,
        notificationService: bundle.notificationService
    )
    try! bundle.notificationService.save()
    
    return NotificationsView(vm: vm)
        .serviceBundle(bundle)
        .environmentObject(AppState(bundle: bundle))
        .environmentObject(SubscriptionManager())
        .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
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
        .environmentObject(AppState(bundle: bundle))
        .environmentObject(SubscriptionManager())
        .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
}
