//
//  MainView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI


struct BudgetView: View {
    
    @StateObject var vm: BudgetViewModel
    @State var path = NavigationPath()
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var budgetService: BudgetService
    @EnvironmentObject var dataService: DataService
    
    @State var transactionSheet: Bool = false
    @State var editBudgetSheetOpen: Bool = false
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                ZStack {
                    Button {
                        appState.unselectBudget()
                    } label: {
                        Text(vm.budget.name ?? "Unknown")
                            .font(.title2)
                            .tint(.black)
                    }
                    .frame(maxWidth: .infinity)
                    Button {
                        editBudgetSheetOpen.toggle()
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding([.trailing], 10)
                }
                Text(vm.getPeriodName())
                    .font(.caption)
                    .padding([.horizontal], 10)
                    .background(RoundedRectangle(cornerRadius: 3).foregroundColor(.green))
                TabView {
                    BudgetOverviewView(vm: vm, transactionSheet: $transactionSheet)
                        .tabItem { Image(systemName: "house") }
                    CategoryListView(vm: vm)
                        .tabItem { Image(systemName: "menucard") }
                    TransactionListView(vm: vm)
                        .tabItem { Image(systemName: "list.clipboard") }
                    BudgetStatsView()
                        .tabItem { Image(systemName: "chart.pie") }
                }
                .padding([.horizontal], 15)
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .sheet(isPresented: $transactionSheet, onDismiss: onCategoryUpdated) {
                AnyView(TransactionSheetView(vm: TransactionSheetViewModel(budget: vm.budget, budgetService: budgetService)))
                    .presentationDetents([.medium])
            }
            .fullScreenCover(isPresented: $editBudgetSheetOpen, onDismiss: onBudgetUpdated) {
                BudgetWizardView(
                    vm: BudgetWizardViewModel(vm.budget, budgetService: budgetService, dataService: dataService),
                    editMode: true
                )
            }
            .onAppear {
                vm.updateAmounts()
            }
        }
    }
    
    func onBudgetUpdated() {
        
    }
    
    func onCategoryUpdated() {
        vm.updateAmounts()
    }
    
}

#Preview {
    let bundle = ServiceBundle.preview
    
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    
    let appState = AppState(budgetService: bundle.budgetService)
    appState.selectBudget(budget)
    
    if let vm = appState.budgetViewModel(budget) {
        return BudgetView(vm: vm)
            .environmentObject(appState)
            .serviceBundle(bundle)
    } else {
        return Text("Seomthing went wrong")
    }
}
