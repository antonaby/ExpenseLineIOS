//
//  NotificationViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 07.07.24.
//

import Foundation


class NotificationViewModel: ObservableObject {
    
    @Published var notification: NotificationEntity
    
    private let notificationService: NotificationService
    
    init(notification: NotificationEntity, notificationService: NotificationService) {
        self.notification = notification
        self.notificationService = notificationService
    }
    
    func reloadNotification() {
        notificationService.refreshNotification(notification)
        objectWillChange.send()
    }
    
    func isActive() -> Bool {
        notification.typeValue != .nonotification && notification.enabled
    }
    
}
