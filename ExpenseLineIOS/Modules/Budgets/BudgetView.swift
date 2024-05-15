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
    @State var changePeriodSheetOpen: Bool = false
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                VStack {
                    HStack {
                        Button {
                            appState.unselectBudget()
                        } label: {
                            Text(vm.budget.name ?? "Unknown")
                                .font(.largeTitle)
                                .tint(.black)
                        }
                        Button {
                            editBudgetSheetOpen.toggle()
                        } label: {
                            Image(systemName: "pencil")
                                .font(.title3)
                                .tint(.green)
                        }
                    }
                    PeriodView()
                }
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(Color.white)
                ZStack(alignment: .bottomTrailing) {
                    TabView {
                        BudgetOverviewView(vm: vm)
                            .tabItem { Image(systemName: "house") }
                        CategoryListView(vm: vm)
                            .tabItem { Image(systemName: "menucard") }
                        TransactionListView(vm: vm)
                            .tabItem { Image(systemName: "list.clipboard") }
                        BudgetStatsView()
                            .tabItem { Image(systemName: "chart.pie") }
                    }
                    .padding([.horizontal], 20)
                    AddExpenseButton {
                        transactionSheet.toggle()
                    }
                    .offset(x: -20, y: -70)
                }
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .sheet(isPresented: $transactionSheet, onDismiss: onCategoryUpdated) {
                TransactionSheetView(
                    vm: TransactionSheetViewModel(transaction: nil,
                                                  budget: vm.budget,
                                                  currency: vm.currency,
                                                  budgetService: budgetService))
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $changePeriodSheetOpen) {
                PeriodListView(selected: $vm.period, 
                               vm: PeriodListViewModel(budget: vm.budget, budgetService: budgetService))
                    .presentationDetents([.large, .medium])
                    .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $editBudgetSheetOpen, onDismiss: onBudgetUpdated) {
                BudgetWizardView(
                    vm: BudgetWizardViewModel(vm.budget, budgetService: budgetService, dataService: dataService),
                    editMode: true
                )
                
            }
            .onAppear {
                vm.loadCurrentBudgetPeriod()
                vm.updateAmounts()
            }
        }
    }
    
    @ViewBuilder
    func PeriodView() -> some View {
        if let period = vm.period {
            Button {
                changePeriodSheetOpen.toggle()
            } label: {
                Text(period.currentMonth)
            }
            .buttonStyle(.borderless)
            .tint(.green)
            .padding(.bottom, 5)
        } else {
            Text("Loading...")
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
    
    let currentDate = Date()
        
    let period1 = PeriodEntity(context: dm.viewContext)
    period1.id = UUID()
    period1.startsAt = currentDate.firstDayOfMonth()
    period1.endsAt = currentDate.lastDayOfMonth()
    period1.budget = budget
    
    let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
    let period2 = PeriodEntity(context: dm.viewContext)
    period2.id = UUID()
    period2.startsAt = previousMonth.firstDayOfMonth()
    period2.endsAt = previousMonth.lastDayOfMonth()
    period2.budget = budget
    
    let previousMonth2 = Calendar.current.date(byAdding: .month, value: -2, to: currentDate)!
    let period3 = PeriodEntity(context: dm.viewContext)
    period3.id = UUID()
    period3.startsAt = previousMonth2.firstDayOfMonth()
    period3.endsAt = previousMonth2.lastDayOfMonth()
    period3.budget = budget
    
    let appState = AppState(budgetService: bundle.budgetService)
    appState.selectBudget(budget)
    
    do {
        try dm.sync()
    } catch {
        print("Something went wrong \(error)")
    }
    
    return BudgetView(vm: BudgetViewModel(
        budget: budget, budgetService: bundle.budgetService, dataService: bundle.dataService
    ))
        .environmentObject(appState)
        .serviceBundle(bundle)
}
