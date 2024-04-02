//
//  MainView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 02.04.24.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if let budget = appState.budget {
                BudgetView(vm: appState.resolver.budgetViewModel(budget), path: .constant(NavigationPath()))
                    .environmentObject(appState.resolver)
                    .environmentObject(appState)
            } else {
                BudgetListView(vm: appState.resolver.budgetListViewModel())
                    .environmentObject(appState.resolver)
                    .environmentObject(appState)
            }
        }.onAppear {
            appState.loadBudget()
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AppState())
}
