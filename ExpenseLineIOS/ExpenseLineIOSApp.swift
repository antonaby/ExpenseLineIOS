//
//  ExpenseLineIOSApp.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI

@main
struct ExpenseLineIOSApp: App {
    
    let serviceBundle = ServiceBundle()
    
    var body: some Scene {
        WindowGroup {
            MainView(appState: AppState(budgetService: serviceBundle.budgetService, settingsService: serviceBundle.settingsService))
                .serviceBundle(serviceBundle)
        }
    }
}
