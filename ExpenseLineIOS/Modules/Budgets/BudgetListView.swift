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
            ForEach(vm.budgets) { budget in
                VStack {
                    Button {
                        appState.selectBudget(budget)
                    } label: {
                        HStack {
                            Text(budget.name ?? "Unknown")
                                .font(.title2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.horizontal], 10)
                        .padding([.vertical], 5)
                        .background(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 1))
                        .tint(.black)
                    }
                }
            }
            HStack {
                Spacer()
                Button {
                    isCreateBudgetSheetOpen.toggle()
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .padding([.horizontal], 10)
        .onAppear {
            vm.loadBudgets()
        }
        .sheet(isPresented: $isCreateBudgetSheetOpen, onDismiss: onBudgetCreated) {
            CreateBudgetSheetView(vm: resolver.createBudgetSheetViewModel())
                .presentationDetents([.medium])
        }
    }
    
    func onBudgetCreated() {
        vm.loadBudgets()
    }
    
}

#Preview {
    let dm = DependencyResolver.preview.databaseManager()
    let budget1 = BudgetEntity(context: dm.viewContext)
    budget1.id = UUID()
    budget1.name = "Budget 1"
    
    let budget2 = BudgetEntity(context: dm.viewContext)
    budget2.id = UUID()
    budget2.name = "Budget 2"
    
    dm.save()
    
    return BudgetListView(vm: DependencyResolver.preview.budgetListViewModel())
        .environmentObject(AppState())
        .environmentObject(DependencyResolver.preview)
}
