//
//  BaseView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import SwiftUI


struct BudgetListView: View {
    
    @EnvironmentObject var subscriptionService: SubscriptionService
    @EnvironmentObject var appState: AppState
    
    @Binding var showNewBudgetPage: Bool
    @StateObject var vm: BudgetListViewModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                NavigationLink {
                    SettingsView()
                        .navigationTitle("Settings")
                } label: {
                    Image(systemName: "gear")
                        .font(.title2)
                }
                .tint(Color("FrDefault"))
            }
            IconView(name: "piggy-bank", color: Color("FrDefault"), size: 100)
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
                                        NavigationLink(value: budget) {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(Color("FrDefault"))
                                        Button(role: .destructive) {
                                            vm.deleteBudget(budget)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        .tint(Color("Accent1"))
                                    } label: {
                                        Image(systemName: "ellipsis").font(.title2)
                                            .frame(width: 35, height: 30, alignment: .center)
                                    }
                                }
                                .tint(.black)
                            }
                        }
                    }
                }
            }
            .padding(.top, 20)
            Button {
                if subscriptionService.checkMaxBudgetCount() {
                    showNewBudgetPage.toggle()
                } else {
                    appState.showPaywall()
                }
            } label: {
                ButtonTextView()
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
        .background(Color("BgDefault"))
        .onAppear {
            vm.loadBudgets()
        }
    }
    
    @ViewBuilder
    func NoBudgetView() -> some View {
        VStack {
            Text("No budgets yet...")
                .font(.title)
        }
    }
    
    @ViewBuilder
    func ButtonTextView() -> some View {
        Text("Create")
            .font(.title2)
            .frame(maxWidth: .infinity)
            .padding(10)
            .foregroundStyle(.white)
            .background(RoundedRectangle(cornerRadius: 20).foregroundStyle(Color("FrDefault")))
    }
    
}

#Preview("No budgets") {
    let bundle = ServiceBundle.preview
  
    let appState = AppState(bundle: bundle)
    return BudgetListView(showNewBudgetPage: .constant(false),
                          vm: BudgetListViewModel(budgetService: bundle.budgetService))
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
        return BudgetListView(showNewBudgetPage: .constant(false),
                              vm: BudgetListViewModel(budgetService: bundle.budgetService))
            .environmentObject(appState)
            .serviceBundle(bundle)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
