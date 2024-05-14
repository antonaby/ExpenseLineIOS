//
//  MainView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 02.04.24.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var budgetService: BudgetService
    @EnvironmentObject var dataServise: DataService
    @StateObject var appState: AppState
    
    var body: some View {
        VStack {
            if let budget = appState.budget {
                BudgetView(vm: BudgetViewModel(
                    budget: budget,
                    budgetService: budgetService,
                    dataService: dataServise)
                )
            } else {
                BudgetListView(vm: BudgetListViewModel(budgetService: budgetService, dataService: dataServise))
            }
        }
        .environmentObject(appState)
        .onAppear {
            appState.loadBudget()
        }
    }
}

#Preview {
    let bundle = ServiceBundle.preview
    return MainView(appState: AppState(budgetService: bundle.budgetService))
        .serviceBundle(bundle)
}
