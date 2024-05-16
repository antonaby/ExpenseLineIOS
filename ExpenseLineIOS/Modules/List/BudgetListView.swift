//
//  BaseView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import SwiftUI


struct BudgetListView: View {
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var vm: BudgetListViewModel
    @State var isWizzardOpen = false
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
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
                                                vm.selectedBudget = budget
                                            } label: {
                                                Text("Edit")
                                            }
                                            Button(role: .destructive) {
                                                vm.deleteBudget(budget)
                                            } label: {
                                                Text("Delete")
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis").font(.title2)
                                                .padding(.leading, 10)
                                        }
                                    }
                                    .tint(.black)
                                }
                            }
                        }
                    }
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                }
            }
            Button {
                isWizzardOpen.toggle()
            } label: {
                Text("Create")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding(.horizontal, 20)
        .background(Color(uiColor: .secondarySystemBackground))
        .onAppear {
            vm.loadBudgets()
        }
        .fullScreenCover(item: $vm.selectedBudget, onDismiss: onBudgetCreated) { budget in
            BudgetWizardView(vm: vm.budgetWizzardViewModel(), editMode: true)
        }
        .fullScreenCover(isPresented: $isWizzardOpen, onDismiss: onBudgetCreated) {
            BudgetWizardView(vm: vm.budgetWizzardViewModel(), editMode: false)
        }
    }
    
    func onBudgetCreated() {
        vm.selectedBudget = nil
        vm.loadBudgets()
    }
    
    @ViewBuilder
    func NoBudgetView() -> some View {
        VStack {
            Image(systemName: "case")
                .font(.title)
            Text("Let's create a new budget!")
                .font(.title)
        }
    }
    
}

#Preview("No budgets") {
    let bundle = ServiceBundle.preview
  
    do {
        let appState = AppState(budgetService: bundle.budgetService)
        return BudgetListView(vm:
                                BudgetListViewModel(budgetService: bundle.budgetService,
                                                    dataService: bundle.dataService))
            .environmentObject(appState)
    } catch {
        return Text("Something went wrong \(error)")
    }
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
        let appState = AppState(budgetService: bundle.budgetService)
        return BudgetListView(vm:
                                BudgetListViewModel(budgetService: bundle.budgetService,
                                                    dataService: bundle.dataService))
            .environmentObject(appState)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
