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
    @EnvironmentObject var notificationService: NotificationService
    
    @State var transactionSheet: Bool = false
    @State var editBudgetSheetOpen: Bool = false
    @State var changePeriodSheetOpen: Bool = false
    @State var settingsSheetOpen: Bool = false
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                VStack {
                    HStack {
                        Button {
                            editBudgetSheetOpen.toggle()
                        } label: {
                            Text(vm.budget.name ?? "Unknown")
                                .font(.title2)
                                .tint(.black)
                        }
                    }
                    PeriodView()
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .background(Color.white)
                .overlay(alignment: .topLeading) {
                    Button {
                        appState.unselectBudget()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .padding(.leading, 10)
                            .padding(.top, 5)
                    }
                    .tint(.green)
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        settingsSheetOpen.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .font(.title2)
                            .padding(.trailing, 10)
                            .padding(.top, 5)
                    }
                    .tint(.green)
                }
                ZStack(alignment: .bottomTrailing) {
                    TabView(selection: $vm.currenPage) {
                        BudgetOverviewView(vm: vm)
                            .tabItem { Image(systemName: "house") }
                            .tag(BudgetViewPage.overview)
                        CategoryListView(vm: CategoryListViewModel(parent: vm, budgetService: budgetService))
                            .tabItem { Image(systemName: "dollarsign.arrow.circlepath") }
                            .tag(BudgetViewPage.categories)
                        TransactionListView(vm: TransactionListViewModel(parent: vm, budgetService: budgetService))
                            .tabItem { Image(systemName: "list.bullet") }
                            .tag(BudgetViewPage.transactions)
                        BudgetStatsView(vm: vm)
                            .tabItem { Image(systemName: "chart.pie") }
                            .tag(BudgetViewPage.stats)
                    }
                    AddExpenseButton {
                        transactionSheet.toggle()
                    }
                    .offset(x: -20, y: -70)
                }
            }
            .sheet(isPresented: $transactionSheet, onDismiss: onTransactionUpdated) {
                TransactionSheetView(
                    vm: TransactionSheetViewModel(transaction: nil,
                                                  budget: vm.budget,
                                                  currency: vm.currency,
                                                  budgetService: budgetService))
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $changePeriodSheetOpen, onDismiss: onPeriodUpdated) {
                PeriodListView(selected: $vm.period,
                               vm: PeriodListViewModel(budget: vm.budget, budgetService: budgetService))
                    .presentationDetents([.large, .medium])
                    .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $editBudgetSheetOpen, onDismiss: onBudgetUpdated) {
                BudgetWizardView(
                    vm: BudgetWizardViewModel(vm.budget, 
                                              budgetService: budgetService,
                                              dataService: dataService,
                                              notificationService: notificationService),
                    editMode: true
                )
            }
            .fullScreenCover(isPresented: $settingsSheetOpen, onDismiss: onBudgetUpdated) {
                SettingsView()
            }
            .navigationDestination(for: PlanCategoryEntity.self) { category in
                CategoryView(vm: CategoryViewModel(
                    category: category,
                    period: vm.period,
                    budget: vm.budget,
                    currency: vm.currency,
                    budgetService: budgetService)
                )
                .navigationTitle("Category")
            }
        }
        .onDisappear {
            vm.cancelAll()
        }
    }
    
    @ViewBuilder
    func PeriodView() -> some View {
        Button {
            changePeriodSheetOpen.toggle()
        } label: {
            Text(vm.period.currentMonth)
        }
        .buttonStyle(.borderless)
        .tint(.green)
        .padding(.bottom, 5)
    }
    
    func onBudgetUpdated() {
        vm.reloadBudget()
    }
    
    func onPeriodUpdated() {
        vm.reloadPage()
    }
    
    func onTransactionUpdated() {
        vm.sendTransactionUpdated()
    }
    
}

#Preview {
    let bundle = ServiceBundle.preview
    
    let dm = bundle.databaseManager
    let budgetService = bundle.budgetService
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
    
    let plannedCategory = budgetService.newCategoryEntity(budget)
    plannedCategory.typeValue = .income
    plannedCategory.amountDecimal = 2000
    plannedCategory.iconName = "in-salary"
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
    category1.id = UUID()
    category1.name = "Preview 1"
    category1.amount = 0
    category1.percent = 0.2
    category1.iconName = "fl-groceries"
    category1.typeValue = .outcomePercent
    category1.createdAt = Date()
    category1.budget = budget
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Preview 2"
    category2.amount = 2000
    category2.percent = 0
    category2.iconName = "fi-rent"
    category2.typeValue = .outcomeFixed
    category2.createdAt = Date()
    category2.budget = budget
    
    let transaction1 = budgetService.newTransactionEntity(budget)
    transaction1.name = "Test 1"
    transaction1.amountDecimal = 12
    transaction1.createdAt = Date()
    transaction1.category = category1
    
    let transaction2 = budgetService.newTransactionEntity(budget)
    transaction2.name = "Test 2"
    transaction2.amountDecimal = 40
    transaction2.createdAt = Date()
    transaction2.category = category1
    
    let transaction3 = budgetService.newTransactionEntity(budget)
    transaction3.name = "Test 3"
    transaction3.amountDecimal = 300
    transaction3.createdAt = Date()
    transaction3.category = category2
    
    let transaction4 = budgetService.newTransactionEntity(budget)
    transaction4.name = "Test 4"
    transaction4.amountDecimal = 800
    transaction4.createdAt = Date()
    transaction4.category = category2
    
    let appState = AppState(budgetService: bundle.budgetService, settingsService: bundle.settingsService)
    appState.selectBudget(budget)
    
    do {
        var period = try budgetService.getOrCreateLastPeriod(budget)
        try dm.sync()
        return BudgetView(vm: BudgetViewModel(
            budget: budget, period: period, budgetService: bundle.budgetService, dataService: bundle.dataService
        ))
            .environmentObject(appState)
            .serviceBundle(bundle)
    } catch {
        print("Something went wrong \(error)")
        return Text("Something went wrong \(error)")
    }
}
