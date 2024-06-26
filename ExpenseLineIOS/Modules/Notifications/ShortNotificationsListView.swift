//
//  ShortNotificationsListView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 26.06.24.
//

import SwiftUI

struct ShortNotificationsListView: View {
    
    @EnvironmentObject var formatters: FormattersHolder
    
    @Binding var notifications: [NotificationEntity]
    var showCategory: Bool = true
    
    private let currentTime: DateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
    
    var body: some View {
        VStack(spacing: 10) {
            if !notifications.isEmpty {
                ForEach($notifications) { $notification in
                    switch notification.typeValue {
                    case .nonotification:
                        NoNotificationShortView(notification)
                    case .daily:
                        DailyNotificationShortView(notification)
                    case .exact:
                        ExactNotificationShortView(notification)
                    case .weekly:
                        WeeklyNotificationShortView(notification)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func NoNotificationShortView(_ notification: NotificationEntity) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "bell.slash")
            NotificationName(notification)
            NotificationCategoryView(notification)
        }
    }
    
    @ViewBuilder
    func DailyNotificationShortView(_ notification: NotificationEntity) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "bell")
            VStack {
                NotificationName(notification)
                if let date = notification.date {
                    HStack(spacing: 5) {
                        Text("Daily")
                        Text(formatters.formatHour(date))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.caption)
                }
            }
            NotificationCategoryView(notification)
        }
        .foregroundStyle(rowColor(notification))
    }
    
    @ViewBuilder
    func ExactNotificationShortView(_ notification: NotificationEntity) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "bell")
            VStack {
                NotificationName(notification)
                if let date = notification.date {
                    Text(formatters.formatDate(date))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)
                }
            }
            NotificationCategoryView(notification)
        }
        .foregroundStyle(rowColor(notification))
    }
    
    @ViewBuilder
    func WeeklyNotificationShortView(_ notification: NotificationEntity) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "bell")
            VStack {
                NotificationName(notification)
                if let date = notification.date {
                    HStack(spacing: 5) {
                        Text(weekDaySymbol())
                        Text(formatters.formatHour(date))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.caption)
                }
            }
            NotificationCategoryView(notification)
        }
        .foregroundStyle(rowColor(notification))
    }
    
    @ViewBuilder
    func NotificationName(_ notification: NotificationEntity) -> some View {
        Text(notification.nameValue)
            .frame(maxWidth: .infinity, alignment: .leading)
            .truncationMode(.tail)
            .lineLimit(2)
            .strikethrough(isAfter(notification))
    }
    
    @ViewBuilder
    func NotificationCategoryView(_ notification: NotificationEntity) -> some View {
        if let category = notification.category, showCategory {
            HStack {
                Text(category.nameValue)
                IconView(name: category.iconNameValue, color: category.colorValue, size: 25)
            }
            .font(.caption)
        }
    }
    
    func rowColor(_ notification: NotificationEntity) -> Color {
        if isAfter(notification) {
            return .gray
        }
        
        return .black
    }
    
    func isAfter(_ notification: NotificationEntity) -> Bool {
        if let date = notification.date {
            let notificationDate = Calendar.current.dateComponents([.hour, .minute], from: date)
            
            if let currentHour = currentTime.hour,
               let currentMinute = currentTime.minute,
               let notificationHour = notificationDate.hour,
               let notificationMinute = notificationDate.minute {
                    
                if currentHour > notificationHour {
                    return true
                }
                
                if currentHour < notificationHour {
                    return false
                }
                
                if currentMinute > notificationMinute {
                    return true
                }
                
                if currentMinute < notificationMinute {
                    return false
                }
            }
        }
        
        return false
    }
    
    func weekDaySymbol() -> String {
        Calendar.current.shortWeekdaySymbols[Date().currentWeekDay() - 1]
    }
    
}

#Preview {
    let bundle = ServiceBundle.preview
    let budgetService = bundle.budgetService
    let budget = budgetService.newBudgetEntity()
    
    let category = budgetService.newCategoryEntity(budget)
    category.typeValue = .outcomeFixed
    category.name = "Rreview"
    category.iconName = "fi-loan"
    
    let notification1 = budgetService.newNotificationEntity(budget)
    notification1.name = "Preview 1"
    notification1.typeValue = .exact
    notification1.date = Date().plusHour(1)
    notification1.enabled = true
    notification1.category = category
    
    let notification2 = budgetService.newNotificationEntity(budget)
    notification2.name = "Preview 2"
    notification2.typeValue = .daily
    notification2.date = Date()
    notification2.enabled = true
    
    let notification3 = budgetService.newNotificationEntity(budget)
    notification3.name = "Preview 3"
    notification3.typeValue = .weekly
    notification3.date = Date()
    notification3.weekDaysArr = [1, 2, 3, 4, 5, 6, 7]
    notification3.enabled = true
    
    return ShortNotificationsListView(
        notifications: .constant([notification1, notification2, notification3]))
    .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
    
}
