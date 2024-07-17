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
    private let analyticsService: AnalyticsService
    
    init(notification: NotificationEntity, notificationService: NotificationService, analyticsService: AnalyticsService) {
        self.notification = notification
        self.notificationService = notificationService
        self.analyticsService = analyticsService
    }
    
    func reloadNotification() {
        notificationService.refreshNotification(notification)
        objectWillChange.send()
    }
    
    func isActive() -> Bool {
        notification.typeValue != .nonotification && notification.enabled
    }
    
    func deleteNotification() {
        do {
            notificationService.deleteNotification(notification)
            try notificationService.save()
        } catch {
            logErrorEvent(error)
            print("Something went wrong \(error)")
        }
    }
    
    private func logErrorEvent(_ error: Error) {
        analyticsService.logError(place: "notification", error: error)
    }
    
}
