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
    
    private let resolver = DependencyResolver(assemblies: DatabaseManagerBundle(), ServiceBundle(), ModulesBundle())
    
    var body: some Scene {
        WindowGroup {
            if appState.budget != nil {
                BudgetView(vm: resolver.budgetViewModel(), path: .constant(NavigationPath()))
                    .environmentObject(resolver)
                    .environmentObject(appState)
            } else {
                BudgetListView(vm: resolver.budgetListViewModel())
                    .environmentObject(resolver)
                    .environmentObject(appState)
            }
        }
    }
}
