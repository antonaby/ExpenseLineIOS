//
//  NotificationService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 30.05.24.
//

import Foundation
import UserNotifications

enum NotificationServiceError: Error {
    
    case SaveError(msg: String, reason: Error?)
    
}

class NotificationService: ObservableObject {
    
    private let dm: DatabaseManager
    
    init(dm: DatabaseManager) {
        self.dm = dm
    }
    
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
        content.body = "Have you added your spendings today?"
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
    
    func sheduleNotification(_ notification: NotificationEntity) throws {
        var requests: [UNNotificationRequest] = []
        
        do {
            removeOldEntries(notification)
            
            switch notification.typeValue {
            case .exact:
                requests = sheduleExactNotification(notification)
            case .everyday:
                requests = sheduleEverydayNotification(notification)
            case .weekdays:
                requests = sheduleWeekdayNotification(notification)
            case .days:
                requests = sheduleDaysNotification(notification)
            }
            
            try dm.sync()
        } catch {
            throw NotificationServiceError.SaveError(msg: "Failed to save notifications", reason: error)
        }
        
        if !requests.isEmpty {
            for request in requests {
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    func cancelNotification(_ notification: NotificationEntity) throws {
        let entires = notification.entries?.allObjects as? [NotificationEntryEntity] ?? []
        if entires.isEmpty {
            return
        }
        
        for entry in entires {
            guard let entryId = entry.id else { continue }
            
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: [entryId.uuidString])
        }
        
        do {
            removeOldEntries(notification)
            try dm.sync()
        } catch {
            throw NotificationServiceError.SaveError(msg: "Failed to delete notifications", reason: error)
        }
    }
    
    private func prepareContent(_ notification: NotificationEntity) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "ExpenseLine"
        content.body = notification.nameValue
        content.sound = .default
        content.interruptionLevel = .active
        
        return content
    }
    
    private func createEntry(id: UUID, notification: NotificationEntity) -> NotificationEntryEntity {
        let entry = NotificationEntryEntity(context: dm.viewContext)
        entry.id = id
        entry.createdAt = Date()
        entry.notification = notification
        
        return entry
    }
    
    private func createRequest(id: UUID, matching: DateComponents, content: UNMutableNotificationContent) -> UNNotificationRequest {
        let trigger = UNCalendarNotificationTrigger(dateMatching: matching, repeats: true)
        return UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
    }
    
    private func sheduleExactNotification(_ notification: NotificationEntity) -> [UNNotificationRequest] {
        guard let date = notification.date else { return [] }
        
        let content = prepareContent(notification)
        
        let entryId = UUID()
        _ = createEntry(id: entryId, notification: notification)
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let request = createRequest(id: entryId, matching: dateComponents, content: content)
        
        return [request]
    }
    
    private func sheduleEverydayNotification(_ notification: NotificationEntity) -> [UNNotificationRequest] {
        guard let date = notification.date else { return [] }
        
        let content = prepareContent(notification)
        
        let entryId = UUID()
        _ = createEntry(id: entryId, notification: notification)
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        let request = createRequest(id: entryId, matching: dateComponents, content: content)
        
        return [request]
    }
    
    private func sheduleWeekdayNotification(_ notification: NotificationEntity) -> [UNNotificationRequest] {
        guard let date = notification.date else { return [] }
        
        let weekDays = notification.weekDaysArr
        if weekDays.isEmpty {
            return []
        }
        
        var requests: [UNNotificationRequest] = []
        let content = prepareContent(notification)
        
        for day in weekDays {
            let entryId = UUID()
            _ = createEntry(id: entryId, notification: notification)
        
            var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
            dateComponents.weekday = day
            let request = createRequest(id: entryId, matching: dateComponents, content: content)
            requests.append(request)
        }
        
        return requests
    }
    
    private func sheduleDaysNotification(_ notification: NotificationEntity) -> [UNNotificationRequest] {
        guard let date = notification.date else { return [] }
        
        let days = notification.daysArr
        if days.isEmpty {
            return []
        }
        
        var requests: [UNNotificationRequest] = []
        let content = prepareContent(notification)
        
        for day in days {
            let entryId = UUID()
            _ = createEntry(id: entryId, notification: notification)
        
            var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
            dateComponents.day = day
            let request = createRequest(id: entryId, matching: dateComponents, content: content)
            requests.append(request)
        }
        
        return requests
    }
    
    private func removeOldEntries(_ notification: NotificationEntity) {
        let entires = notification.entries?.allObjects as? [NotificationEntryEntity] ?? []
        
        for entry in entires {
            dm.viewContext.delete(entry)
        }
    }
    
}
