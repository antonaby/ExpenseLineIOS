//
//  BaseView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import SwiftUI


struct BudgetListView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var resolver: DependencyResolver
    
    @StateObject var vm: BudgetListViewModel
    @State var isCreateBudgetSheetOpen = false
    
    var body: some View {
        VStack {
            addControls()
            budgetList()
        }.onAppear {
            vm.loadBudgets()
        }.sheet(isPresented: $isCreateBudgetSheetOpen, onDismiss: onBudgetCreated) {
            CreateBudgetSheetView(vm: resolver.createBudgetSheetViewModel())
                .presentationDetents([.medium])
        }
    }
    
    func onBudgetCreated() {
        vm.loadBudgets()
    }
    
    @ViewBuilder
    func addControls() -> some View {
        Button {
            isCreateBudgetSheetOpen.toggle()
        } label: {
            Text("Add")
        }
    }
    
    @ViewBuilder
    func budgetList() -> some View {
        ForEach(vm.budgets) { budget in
            VStack {
                Button {
                    appState.selectBudget(budget)
                } label: {
                    Text(budget.name ?? "Unknown")
                }
            }
        }
    }
}

#Preview {
    BudgetListView(vm: DependencyResolver.preview.budgetListViewModel())
        .environmentObject(AppState())
        .environmentObject(DependencyResolver.preview)
}
