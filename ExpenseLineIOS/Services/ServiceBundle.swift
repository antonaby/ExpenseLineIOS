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
    
    init(inMemory: Bool = false) {
        databaseManager = DatabaseManager()
        databaseManager.initializeStore(inMemory: inMemory)
        budgetService = BudgetService(dm: databaseManager)
        dataService = DataService()
    }
    
}

struct ServiceBundleViewModifier: ViewModifier {
    
    let bundle: ServiceBundle
    
    func body(content: Content) -> some View {
        content
            .environmentObject(bundle.databaseManager)
            .environmentObject(bundle.budgetService)
            .environmentObject(bundle.dataService)
    }
    
}
