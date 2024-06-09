//
//  NotificationViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 08.06.24.
//

import Foundation


class NotificationsViewModel: ObservableObject {
    
    private let notificationService: NotificationService
    
    init(notificationService: NotificationService) {
        self.notificationService = notificationService
    }
    
}
