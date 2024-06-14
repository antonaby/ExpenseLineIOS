//
//  NotificationViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 08.06.24.
//

import Foundation


class NotificationsViewModel: ObservableObject {
    
    @Published var notifications: [NotificationEntity] = []
    
    private let budget: BudgetEntity
    private let notificationService: NotificationService
    
    init(budget: BudgetEntity, notificationService: NotificationService) {
        self.budget = budget
        self.notificationService = notificationService
    }
    
    func loadNotifications() {
        do {
            notifications = try notificationService.getNotifications(budget: budget)
        } catch {
            // TODO: handle error
            print("Something went wrong \(error)")
        }
    }
    
    func newNotification() -> NotificationEntity {
        let entiry = notificationService.newNotificationEntity(budget)
        entiry.typeValue = .exact
        entiry.enabled = true
        entiry.date = Date().plusHour(1)
        
        return entiry
    }
    
    func deleteNotification(_ notification: NotificationEntity) {
        do {
            try notificationService.deleteNotification(notification)
        } catch {
            // TODO: handle error
            print("Something went wrong \(error)")
        }
    }
    
    func resheduleNotification(_ notification: NotificationEntity) {
        do {
            try notificationService.sheduleNotification(notification)
        } catch {
            // TODO: handle error
            print("Something went wrong \(error)")
        }
    }
    
}
