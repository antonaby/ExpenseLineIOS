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
        ServiceBundle(inMemory: true)
    }
    
    let databaseManager: DatabaseManager
    let budgetService: BudgetService
    let dataService: DataService
    let settingsService: SettingsService
    let notificationService: NotificationService
    
    init(inMemory: Bool = false) {
        databaseManager = DatabaseManager()
        databaseManager.initializeStore(inMemory: inMemory)
        budgetService = BudgetService(dm: databaseManager)
        dataService = DataService(budgetService: budgetService)
        settingsService = SettingsService()
        notificationService = NotificationService()
    }
    
}

extension View {
    
    func serviceBundle(_ bundle: ServiceBundle) -> some View {
        self.environmentObject(bundle.databaseManager)
            .environmentObject(bundle.budgetService)
            .environmentObject(bundle.dataService)
            .environmentObject(bundle.settingsService)
            .environmentObject(bundle.notificationService)
    }
    
}
