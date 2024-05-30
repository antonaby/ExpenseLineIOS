//
//  NotificationService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 30.05.24.
//

import Foundation
import UserNotifications


class NotificationService: ObservableObject {
    
    func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { success, error in
                // TODO: handle result
                if success {
                    print("Notification authorization granted.")
                } else if let error = error {
                    print(error.localizedDescription)
                }
        }
    }
    
    func scheduleDailyReminder(budgetId: UUID, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "ExpenseLine"
        content.body = "Have you added you spendings today?"
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: budgetId.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelDailyReminder(budgetId: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [budgetId.uuidString])
    }
    
}
