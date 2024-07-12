//
//  MainView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 02.04.24.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var analytincService: AnalyticsService
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var budgetService: BudgetService
    @EnvironmentObject var dataServise: DataService
    @EnvironmentObject var notificationService: NotificationService
    
    @StateObject var appState: AppState
    
    var body: some View {
        MainView()
            .preferredColorScheme(appState.colorScheme)
            .onAppear {
                analytincService.updateUserId()
            }
    }
    
    @ViewBuilder
    func MainView() -> some View {
        NavigationStack(path: $appState.path) {
            VStack {
                if let budget = appState.budget,
                    let vm = appState.getBudgetViewModel(budget: budget)  {
                    BudgetView(vm: vm)
                } else {
                    BudgetListView(vm: BudgetListViewModel(budgetService: budgetService,
                                                           analyticsService: analytincService))
                }
            }
            .navigationDestination(for: BudgetEntity.self) { budget in
                BudgetWizardView(vm: BudgetWizardViewModel(
                    budget,
                    budgetService: budgetService,
                    dataService: dataServise,
                    notificationService: notificationService,
                    analyticsService: analytincService)
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
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(appState.colorScheme)
        }
        .fullScreenCover(isPresented: $subscriptionManager.paywall) {
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
        .environmentObject(SubscriptionManager(analyticsService: bundle.analyticsService))
}
