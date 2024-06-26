//
//  NotificationViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 08.06.24.
//

import Foundation
import Combine

class NotificationsViewModel: ObservableObject {
    
    var categoryRef: CategoryNotificationsRef
    @Published var notifications: [NotificationEntity] = []
    @Published var todayNotifications: Bool = true
    
    let budget: BudgetEntity
    
    private let budgetService: BudgetService
    private let notificationService: NotificationService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(categoryRef: CategoryNotificationsRef, budget: BudgetEntity, budgetService: BudgetService, notificationService: NotificationService) {
        self.categoryRef = categoryRef
        self.budget = budget
        self.budgetService = budgetService
        self.notificationService = notificationService
        
        $todayNotifications
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.loadNotifications()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadNotifications() {
        if let category = categoryRef.category {
            do {
                notifications = todayNotifications 
                ? try notificationService.getNotificationsForToday(category: category, showNoNotifications: true)
                : try notificationService.getNotifications(category: category)
            } catch {
                // TODO: handle error
                print("Something went wrong \(error)")
            }
        } else {
            do {
                notifications = todayNotifications
                ? try notificationService.getNotificationsForToday(budget: budget, showNoNotifications: false)
                : try notificationService.getNotifications(budget: budget)
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
            try notificationService.save()
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
        
        objectWillChange.send()
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
}
