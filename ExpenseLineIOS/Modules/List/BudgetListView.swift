//
//  BaseView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import SwiftUI


struct BudgetListView: View {
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var settingsService: SettingsService
    @EnvironmentObject var subscriptionLimit: SubscriptionLimitService
    @EnvironmentObject var appState: AppState
    
    @StateObject var vm: BudgetListViewModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                NavigationLink {
                    SettingsView(settings: settingsService)
                        .navigationTitle("Settings")
                } label: {
                    Image(systemName: "gear")
                        .font(.title2)
                }
            }
            IconView(name: "piggy-bank", color: Color.appLink, size: 100)
            ScrollView {
                VStack {
                    if vm.budgets.isEmpty {
                        NoBudgetView()
                    } else {
                        ForEach(vm.budgets) { budget in
                            ContentSizeCardView {
                                HStack {
                                    Button {
                                        appState.selectBudget(budget)
                                    } label: {
                                        Text(budget.name ?? "Unknown")
                                            .font(.title2)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Menu {
                                        Button {
                                            appState.navigateEditBudget(budget)
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        Button(role: .destructive) {
                                            vm.deleteBudget(budget)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis").font(.title2)
                                            .frame(width: 35, height: 30, alignment: .center)
                                    }
                                }
                                .tint(Color.appCardTextColor)
                            }
                        }
                    }
                }
            }
            .padding(.top, 20)
            Button {
                if subscriptionManager.hasProSubscription() || subscriptionLimit.checkMaxBudgetCount() {
                    appState.navigateNewBudgetWizzard()
                } else {
                    subscriptionManager.showPaywall()
                }
            } label: {
                ButtonTextView()
            }
            .padding(.horizontal, 20)
        }
        .tint(Color.appLink)
        .padding(.horizontal, 20)
        .background(Color.appBackground)
        .onAppear {
            vm.loadBudgets()
        }
    }
    
    @ViewBuilder
    func NoBudgetView() -> some View {
        VStack {
            Text("No budgets yet...")
                .font(.title)
                .foregroundStyle(Color.appCardTextColor)
        }
    }
    
    @ViewBuilder
    func ButtonTextView() -> some View {
        Text("Create")
            .font(.title2)
            .frame(maxWidth: .infinity)
            .padding(10)
            .foregroundStyle(Color.appButtonTextColor)
            .background(RoundedRectangle(cornerRadius: 20).foregroundStyle(Color.appLink))
    }
    
}

#Preview("No budgets") {
    let bundle = ServiceBundle.preview
  
    let appState = AppState(bundle: bundle)
    return BudgetListView(vm: BudgetListViewModel(budgetService: bundle.budgetService))
        .environmentObject(appState)
        .serviceBundle(bundle)
}

#Preview("List") {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget1 = BudgetEntity(context: dm.viewContext)
    budget1.id = UUID()
    budget1.name = "Budget 1"
    
    let budget2 = BudgetEntity(context: dm.viewContext)
    budget2.id = UUID()
    budget2.name = "Budget 2"
    
    do {
        try dm.sync()
        let appState = AppState(bundle: bundle)
        return BudgetListView(vm: BudgetListViewModel(budgetService: bundle.budgetService))
            .environmentObject(appState)
            .serviceBundle(bundle)
            .environmentObject(SubscriptionManager())
    } catch {
        return Text("Something went wrong \(error)")
    }
}
