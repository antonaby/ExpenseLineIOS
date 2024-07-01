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
        if let colorScheme = appState.colorScheme {
            MainView()
                .environment(\.colorScheme, colorScheme)
        } else {
            MainView()
        }
    }
    
    @ViewBuilder
    func MainView() -> some View {
        NavigationStack(path: $appState.path) {
            VStack {
                if let budget = appState.budget,
                    let vm = appState.getBudgetViewModel(budget: budget, budgetService: budgetService, dataService: dataServise)  {
                    BudgetView(vm: vm)
                } else {
                    BudgetListView(vm: BudgetListViewModel(budgetService: budgetService))
                }
            }
            .navigationDestination(for: BudgetEntity.self) { budget in
                BudgetWizardView(vm: BudgetWizardViewModel(
                    budget,
                    budgetService: budgetService,
                    dataService: dataServise,
                    notificationService: notificationService)
                )
                .navigationBarBackButtonHidden(true)
                .onUpdateBudget { budget in
                    appState.path.removeLast()
                    DispatchQueue.main.async {
                        appState.selectBudget(budget)
                    }
                }
                .onDismissBudget { budget in
                    appState.path.removeLast()
                }
            }
        }
        .helpButtonVisible(appState.isHelpButtonVisible())
        .tint(Color.appLink)
        .sheet(item: $appState.helpPage) { page in
            HelpView(page: page)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(appState.colorScheme)
        }
        .fullScreenCover(isPresented: $appState.paywall) {
            PaywallView()
                .preferredColorScheme(appState.colorScheme)
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
