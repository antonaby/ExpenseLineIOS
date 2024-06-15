//
//  NotificationService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 30.05.24.
//

import Foundation
import UserNotifications

enum NotificationServiceError: Error {
    
    case FetchError(msg: String, reason: Error?)
    case SaveError(msg: String, reason: Error?)
    case MissingDataError(msg: String, reason: Error?)
    
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
    
    func getWeekDays() -> [NotificationWeekDay] {
        return Calendar
            .current
            .shortWeekdaySymbols
            .enumerated()
            .map { NotificationWeekDay(id: $0.offset + 1, shortName: $0.element) }
    }
    
    func newNotificationEntity(_ budget: BudgetEntity) -> NotificationEntity {
        let entity = NotificationEntity(context: dm.viewContext)
        entity.id = UUID()
        entity.budget = budget
        entity.createdAt = Date()
        
        return entity
    }
    
    func save() throws {
        try dm.sync()
    }
    
    func rollback() {
        dm.rollback()
    }
    
    func getNotificationsForToday(_ budget: BudgetEntity) throws -> [NotificationEntity] {
        let budgetId = try getBudgetId(budget)
        
        let request = NotificationEntity.fetchRequest()
        let startDate = Date().startOfDay()
        let endDate = Date().endOfDay()
        let currentDay = String(Date().currentWeekDay())
        
        request.predicate = NSPredicate(
            format: "budget.id == %@ AND enabled == true AND ((type == 1 AND date BETWEEN {%@, %@}) OR type == 2 OR (type == 3 AND weekDays CONTAINS[cd] %@))",
            budgetId as CVarArg, startDate as NSDate, endDate as NSDate, currentDay as CVarArg)
        
        do {
            return try dm.viewContext.fetch(request)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch notification", reason: error)
        }
    }
    
    func getNotifications(budget: BudgetEntity) throws -> [NotificationEntity] {
        let budgetId = try getBudgetId(budget)
        
        let request = NotificationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "budget.id == %@", budgetId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        do {
            return try dm.viewContext.fetch(request)
        } catch {
            throw NotificationServiceError.FetchError(msg: "Failed to get notifications", reason: error)
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
        if !notification.enabled {
            try cancelNotification(notification)
        }
        
        var requests: [UNNotificationRequest] = []
        
        do {
            removeOldEntries(notification)
            
            switch notification.typeValue {
            case .nonotification:
                try cancelNotification(notification)
            case .exact:
                requests = sheduleExactNotification(notification)
            case .daily:
                requests = sheduleDailyNotification(notification)
            case .weekly:
                requests = sheduleWeeklyNotification(notification)
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
    
    func deleteNotification(_ notification: NotificationEntity) throws {
        try cancelNotification(notification)
        
        do {
            dm.viewContext.delete(notification)
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
    
    private func sheduleDailyNotification(_ notification: NotificationEntity) -> [UNNotificationRequest] {
        guard let date = notification.date else { return [] }
        
        let content = prepareContent(notification)
        
        let entryId = UUID()
        _ = createEntry(id: entryId, notification: notification)
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        let request = createRequest(id: entryId, matching: dateComponents, content: content)
        
        return [request]
    }
    
    private func sheduleWeeklyNotification(_ notification: NotificationEntity) -> [UNNotificationRequest] {
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
    
    private func removeOldEntries(_ notification: NotificationEntity) {
        let entires = notification.entries?.allObjects as? [NotificationEntryEntity] ?? []
        
        for entry in entires {
            dm.viewContext.delete(entry)
        }
    }
    
    private func getBudgetId(_ budget: BudgetEntity) throws -> UUID {
        if let id = budget.id {
            return id
        }
        
        throw NotificationServiceError.MissingDataError(msg: "Missing budget id", reason: nil)
    }
    
}
