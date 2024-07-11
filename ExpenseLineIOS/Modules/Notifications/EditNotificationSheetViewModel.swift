//
//  EditNotificationSheetViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 10.06.24.
//

import Foundation
import Combine


class EditNotificationSheetViewModel: ObservableObject {
    
    @Published var name: String
    @Published var category: PlanCategoryEntity?
    @Published var categories: [PlanCategoryEntity] = []
    @Published var type: NotificationType
    @Published var date: Date
    @Published var enabled: Bool
    @Published var weekDays: Set<Int>
    @Published var isValid: Bool = false
    
    var notification: NotificationEntity
    private var notificationService: NotificationService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(notification: NotificationEntity, notificationService: NotificationService) {
        self.notification = notification
        self.notificationService = notificationService
        
        self.name = notification.nameValue
        self.type = notification.typeValue
        self.date = notification.date ?? Date().plusHour(1)
        self.enabled = notification.enabled
        self.weekDays = Set(notification.weekDaysArr)
        self.category = notification.category
        
        $name
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.checkValidation()
                }
            }
            .store(in: &cancellables)
        
        $type
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.checkValidation()
                }
            }
            .store(in: &cancellables)
        
        $weekDays
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.checkValidation()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadCategories() {
        categories = notification.budget?.categoriesForType([.outcomeFixed, .outcomePercent]) ?? []
    }
    
    func save() {
        notification.name = name
        notification.typeValue = type
        notification.date = date
        notification.weekDaysArr = Array(weekDays)
        notification.enabled = enabled
        notification.category = category
        notification.isNew = false
        
        do {
            try notificationService.sheduleNotification(notification)
        } catch {
            // TODO: handle error
            print("Something went wrong \(error)")
        }
    }
    
    func deleteNotification() {
        do {
            try notificationService.deleteNotification(notification)
            try notificationService.save()
        } catch {
            // TODO: handle error
            print("Something went wrong \(error)")
        }
    }
    
    func rollback() {
        notificationService.rollback()
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
    private func checkValidation() {
        if name.isEmpty {
            isValid = false
            return
        }
        
        if type == .weekly {
            isValid = !weekDays.isEmpty
        } else {
            isValid = true
        }
    }
    
}

