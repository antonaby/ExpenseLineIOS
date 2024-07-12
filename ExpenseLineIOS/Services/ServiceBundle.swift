//
//  ServiceBundle.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 29.03.24.
//

import Foundation
import SwiftUI

struct ServiceBundle {
    
    static var preview: ServiceBundle {
        let bundle = ServiceBundle(inMemory: true)
        bundle.settingsService.setColorScheme(nil)
        return bundle
    }
    
    let databaseManager: DatabaseManager
    let budgetService: BudgetService
    let dataService: DataService
    let settingsService: SettingsService
    let notificationService: NotificationService
    let subscriptionService: SubscriptionLimitService
    let analyticsService: AnalyticsService
    
    init(inMemory: Bool = false) {
        databaseManager = DatabaseManager()
        databaseManager.initializeStore(inMemory: inMemory)
        notificationService = NotificationService(dm: databaseManager)
        budgetService = BudgetService(dm: databaseManager, notificationService: notificationService)
        settingsService = SettingsService()
        analyticsService = AnalyticsService(settingService: settingsService)
        subscriptionService = SubscriptionLimitService(dm: databaseManager, analyticsService: analyticsService)
        dataService = DataService(budgetService: budgetService, analyticsService: analyticsService)
    }
    
}

extension View {
    
    func serviceBundle(_ bundle: ServiceBundle) -> some View {
        self.environmentObject(bundle.databaseManager)
            .environmentObject(bundle.budgetService)
            .environmentObject(bundle.dataService)
            .environmentObject(bundle.settingsService)
            .environmentObject(bundle.notificationService)
            .environmentObject(bundle.subscriptionService)
            .environmentObject(bundle.analyticsService)
    }
    
}
