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
    @Published var type: NotificationType
    @Published var date: Date
    @Published var weekDays: Set<Int>
    @Published var isValid: Bool = false
    
    private var notification: NotificationEntity
    private var notificationService: NotificationService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(notification: NotificationEntity, notificationService: NotificationService) {
        self.notification = notification
        self.notificationService = notificationService
        
        self.name = notification.nameValue
        self.type = notification.typeValue
        self.date = notification.date ?? Date().plusHour(1)
        self.weekDays = Set(notification.weekDaysArr)
        
        isFormValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFormValid in
                guard let self = self else { return }
                self.isValid = isFormValid
            }
            .store(in: &cancellables)
        
        $type
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                if type == .weekly {
                    self?.isValid = !(self?.weekDays.isEmpty ?? true)
                } else {
                    self?.isValid = true
                }
            }
            .store(in: &cancellables)
        
        $weekDays
            .receive(on: DispatchQueue.main)
            .sink { [weak self] days in
                if self?.type == .weekly {
                    self?.isValid = !days.isEmpty
                } else {
                    self?.isValid = true
                }
            }
            .store(in: &cancellables)
    }
    
    func save() {
        notification.name = name
        notification.typeValue = type
        notification.date = date
        notification.weekDaysArr = Array(weekDays)
        
        do {
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
    
}

private extension EditNotificationSheetViewModel {
    
    var isNameValid: AnyPublisher<Bool, Never> {
        $name
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { name in
                name.count > 0
            }
            .eraseToAnyPublisher()
    }
    
    var isFormValid: AnyPublisher<Bool, Never> {
        isNameValid.map {
            $0
        }
        .eraseToAnyPublisher()
    }
    
}
