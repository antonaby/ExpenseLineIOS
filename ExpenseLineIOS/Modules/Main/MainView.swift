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
    @EnvironmentObject var notificationService: NotificationService
    @StateObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            VStack {
                if let budget = appState.budget,
                    let vm = appState.getBudgetViewModel(budget: budget, budgetService: budgetService, dataService: dataServise)  {
                    BudgetView(vm: vm)
                } else {
                    BudgetListView(vm: BudgetListViewModel(
                        budgetService: budgetService,
                        dataService: dataServise,
                        notificationService: notificationService)
                    )
                }
            }
        }
        .tint(Color("FrDefault"))
        .fullScreenCover(isPresented: $appState.paywall) {
            PaywallView()
        }
        .environmentObject(appState)
        .onAppear {
            appState.loadBudget()
        }
    }
}

#Preview {
    let bundle = ServiceBundle.preview
    return MainView(appState: AppState(
        budgetService: bundle.budgetService,
        settingsService: bundle.settingsService)
    )
    .serviceBundle(bundle)
}
