//
//  NotificationViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 08.06.24.
//

import Foundation


class NotificationsViewModel: ObservableObject {
    
    var categoryRef: CategoryNotificationsRef
    @Published var notifications: [NotificationEntity] = []
    
    private let budget: BudgetEntity
    private let budgetService: BudgetService
    private let notificationService: NotificationService
    
    init(categoryRef: CategoryNotificationsRef, budget: BudgetEntity, budgetService: BudgetService, notificationService: NotificationService) {
        self.categoryRef = categoryRef
        self.budget = budget
        self.budgetService = budgetService
        self.notificationService = notificationService
    }
    
    func loadNotifications() {
        if let category = categoryRef.category {
            do {
                notifications = try notificationService.getNotifications(category: category)
            } catch {
                // TODO: handle error
                print("Something went wrong \(error)")
            }
        } else {
            do {
                notifications = try notificationService.getNotifications(budget: budget)
            } catch {
                // TODO: handle error
                print("Something went wrong \(error)")
            }
        }
    }
    
    func newNotification() -> NotificationEntity {
        let entity = notificationService.newNotificationEntity(budget)
        entity.typeValue = .nonotification
        entity.enabled = true
        entity.date = Date().plusHour(1)
        
        if let category = categoryRef.category {
            entity.category = category
        }
        
        return entity
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
