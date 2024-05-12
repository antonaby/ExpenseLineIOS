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
            Spacer()
            ForEach(vm.budgets) { budget in
                VStack {
                    Button {
                        appState.selectBudget(budget)
                    } label: {
                        HStack {
                            Text(budget.name ?? "Unknown")
                                .font(.title2)
                            Spacer()
                            Button {
                                vm.selectedBudget = budget
                            } label: {
                                Text("Edit")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.horizontal], 10)
                        .padding([.vertical], 5)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(lineWidth: 1).background(Color.white))
                        .tint(.black)
                    }
                }
            }
            .padding([.horizontal], 10)
            HStack {
                Spacer()
                Button {
                    isWizzardOpen.toggle()
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .padding([.horizontal], 10)
            Spacer()
        }
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
    
}

#Preview {
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
            .modifier(ServiceBundleViewModifier(bundle: bundle))
    } catch {
        return Text("Something went wrong \(error)")
    }
    
    
}
