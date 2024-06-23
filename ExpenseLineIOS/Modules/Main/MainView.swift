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
        NavigationStack(path: $appState.path) {
            VStack {
                if let budget = appState.budget,
                    let vm = appState.getBudgetViewModel(budget: budget, budgetService: budgetService, dataService: dataServise)  {
                    BudgetView(vm: vm)
                } else {
                    BudgetListView(showNewBudgetPage: $appState.showNewBudgetPage,
                                   vm: BudgetListViewModel(budgetService: budgetService)
                    )
                }
            }
            .navigationDestination(for: BudgetEntity.self) { budget in
                BudgetWizardView(vm: BudgetWizardViewModel(
                    budget,
                    editMode: true,
                    budgetService: budgetService,
                    dataService: dataServise,
                    notificationService: notificationService)
                )
                .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $appState.showNewBudgetPage) {
                BudgetWizardView(vm: appState.newBudgetWizzardViewModel())
                    .navigationBarBackButtonHidden(true)
            }
        }
        .tint(Color("FrDefault"))
        .sheet(item: $appState.helpPage) { page in
            HelpView(page: page)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
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
    return MainView(appState: AppState(bundle: bundle))
    .serviceBundle(bundle)
}
