//
//  ExpenseLineIOSApp.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI

@main
struct ExpenseLineIOSApp: App {
    
    @ObservedObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
        }
    }
}
