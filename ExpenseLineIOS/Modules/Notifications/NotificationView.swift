//
//  NotificationView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 07.07.24.
//

import SwiftUI

struct NotificationView: View {
    
    @EnvironmentObject var analyticsService: AnalyticsService
    @EnvironmentObject var formatters: FormattersHolder
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var notificationService: NotificationService
    
    @StateObject var vm: NotificationViewModel
    @State var showEditSheet: Bool = false
    
    var body: some View {
        ScrollView {
            FlexibleCardView {
                HStack {
                    Image(systemName: vm.isActive() ? "bell" : "bell.slash")
                        .foregroundStyle(Color.appLink)
                        .font(.title)
                    VStack(alignment: .leading) {
                        Text(vm.notification.nameValue)
                        Group {
                            switch vm.notification.typeValue {
                            case .nonotification:
                                NoNotificationView()
                            case .exact:
                                ExactNotificationView()
                            case .daily:
                                DailyNotificationView()
                            case .weekly:
                                WeeklyNotificationView()
                            }
                        }
                        .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .topTrailing) {
                    Button {
                        showEditSheet.toggle()
                    } label: {
                        Image(systemName: "pencil")
                            .padding([.top, .trailing], 5)
                    }
                    .tint(Color.appLink)
                }
            }
            if let category = vm.notification.category {
                FlexibleCardView {
                    HStack {
                        IconView(name: category.iconNameValue)
                            .accessibilityLabel(category.nameValue)
                        Text(category.nameValue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.horizontal, 20)
        .background(Color.appBackground)
        .sheet(isPresented: $showEditSheet, onDismiss: onSheetClosed) {
            EditNotificationSheetView(
                vm: EditNotificationSheetViewModel(
                    notification: vm.notification,
                    notificationService: notificationService,
                    analyticsService: analyticsService))
            .preferredColorScheme(appState.colorScheme)
        }
    }
    
    @ViewBuilder
    func NoNotificationView() -> some View {
        Text("No Signal")
    }
    
    @ViewBuilder
    func ExactNotificationView() -> some View {
        HStack {
            Text("One Time")
            if let date = vm.notification.date {
                Text(formatters.formatDate(date))
            }
        }
    }
    
    @ViewBuilder
    func DailyNotificationView() -> some View {
        HStack {
            Text("Daily")
            if let date = vm.notification.date {
                Text(formatters.formatHour(date))
            }
        }
    }
    
    @ViewBuilder
    func WeeklyNotificationView() -> some View {
        HStack {
            if let date = vm.notification.date {
                Text(formatters.formatHour(date))
            }
            ForEach(notificationService.getWeekDays()) { day in
                Text(day.shortName)
                    .foregroundStyle(
                        vm.notification.weekDaysArr.contains(day.id)
                        ? Color.appLink
                        : Color.appCardTextColor
                    )
                    .underline(vm.notification.weekDaysArr.contains(day.id))
            }
        }
    }
    
    func onSheetClosed() {
        vm.reloadNotification()
    }
    
}

#Preview("No") {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    
    let category = bundle.budgetService.newCategoryEntity(budget)
    category.name = "Preview category"
    category.iconName = "fl-cloth"
    
    let notification = bundle.notificationService.newNotificationEntity(budget)
    notification.name = "Preview"
    notification.category = category
    notification.typeValue = .nonotification
    notification.enabled = true
    notification.date = Date()
    
    return NotificationView(vm: NotificationViewModel(
        notification: notification,
        notificationService: bundle.notificationService)
    )
    .serviceBundle(bundle)
    .environmentObject(AppState(bundle: bundle))
    .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
}

#Preview("Exact") {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    
    let category = bundle.budgetService.newCategoryEntity(budget)
    category.name = "Preview category"
    category.iconName = "fl-cloth"
    
    let notification = bundle.notificationService.newNotificationEntity(budget)
    notification.name = "Preview"
    notification.category = category
    notification.typeValue = .exact
    notification.enabled = true
    notification.date = Date()
    
    return NotificationView(vm: NotificationViewModel(
        notification: notification,
        notificationService: bundle.notificationService)
    )
    .serviceBundle(bundle)
    .environmentObject(AppState(bundle: bundle))
    .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
}


#Preview("Daily") {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    
    let category = bundle.budgetService.newCategoryEntity(budget)
    category.name = "Preview category"
    category.iconName = "fl-cloth"
    
    let notification = bundle.notificationService.newNotificationEntity(budget)
    notification.name = "Preview"
    notification.category = category
    notification.typeValue = .daily
    notification.enabled = true
    notification.date = Date()
    
    return NotificationView(vm: NotificationViewModel(
        notification: notification,
        notificationService: bundle.notificationService)
    )
    .serviceBundle(bundle)
    .environmentObject(AppState(bundle: bundle))
    .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
}

#Preview("Weekly") {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    
    let category = bundle.budgetService.newCategoryEntity(budget)
    category.name = "Preview category"
    category.iconName = "fl-cloth"
    
    let notification = bundle.notificationService.newNotificationEntity(budget)
    notification.name = "Preview"
    notification.category = category
    notification.typeValue = .weekly
    notification.enabled = true
    notification.date = Date()
    notification.weekDaysArr = [1, 3, 6]
    
    return NotificationView(vm: NotificationViewModel(
        notification: notification,
        notificationService: bundle.notificationService)
    )
    .serviceBundle(bundle)
    .environmentObject(AppState(bundle: bundle))
    .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
}
