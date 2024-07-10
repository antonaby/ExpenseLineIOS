//
//  MainView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI

struct BudgetView: View {
    
    @StateObject var vm: BudgetViewModel
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var budgetService: BudgetService
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var settingsService: SettingsService
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var subscriptionLimitService: SubscriptionLimitService
    @EnvironmentObject var analyticsService: AnalyticsService
    
    @State var transactionSheet: Bool = false
    @State var changePeriodSheetOpen: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Button {
                    appState.navigateEditBudget(vm.budget)
                } label: {
                    Text(vm.budget.name ?? "?")
                        .font(.title2)
                        .tint(Color.appCardTextColor)
                }
                PeriodView().bold()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .background(Color.appBackground)
            .overlay(alignment: .topLeading) {
                Button {
                    appState.unselectBudget()
                } label: {
                    HStack(alignment: .center) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                        Text("Budgets")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.appLink)
                    .padding(5)
                }
                .tint(Color.appLink)
            }
            .overlay(alignment: .topTrailing) {
                NavigationLink {
                    SettingsView(settings: settingsService)
                        .navigationTitle("Settings")
                } label: {
                    Image(systemName: "gear")
                        .font(.title2)
                        .padding(.trailing, 20)
                }
                .tint(Color.appLink)
            }
            ZStack(alignment: .bottomTrailing) {
                TabView(selection: $vm.currenPage) {
                    BudgetOverviewView(
                        vm: BudgetOverviewViewModel(
                            parent: vm,
                            budgetService: budgetService,
                            notificationService: notificationService
                        ))
                        .tabItem { Image(systemName: "house") }
                        .tag(BudgetViewPage.overview)
                    CategoryListView(vm: CategoryListViewModel(parent: vm, budgetService: budgetService))
                        .tabItem { Image(systemName: "dollarsign.arrow.circlepath") }
                        .tag(BudgetViewPage.categories)
                    TransactionListView(vm: TransactionListViewModel(parent: vm, budgetService: budgetService))
                        .tabItem { Image(systemName: "wallet.pass") }
                        .tag(BudgetViewPage.transactions)
                    BudgetStatsView(vm: BudgetStatsViewModel(parent: vm, budgetService: budgetService))
                        .tabItem { Image(systemName: "chart.pie") }
                        .tag(BudgetViewPage.stats)
                }
                .accentColor(Color.appLink)
                AddExpenseButton {
                    if subscriptionManager.hasProSubscription()
                        || subscriptionLimitService.checkMaxTransactionCount(period: vm.period, budget: vm.budget) {
                        transactionSheet.toggle()
                    } else {
                        subscriptionManager.showPaywall()
                    }
                }
                .offset(x: -20, y: -70)
                .accessibilityLabel("Add Expenses")
                .accessibilityElement(children: .combine)
            }
        }
        .sheet(isPresented: $transactionSheet, onDismiss: onTransactionUpdated) {
            TransactionSheetView(
                vm: TransactionSheetViewModel(transaction: nil,
                                              budget: vm.budget,
                                              currency: vm.currency,
                                              budgetService: budgetService))
                .presentationDetents([.medium])
                .preferredColorScheme(appState.colorScheme)
        }
        .sheet(isPresented: $changePeriodSheetOpen) {
            PeriodListView(selected: $vm.period,
                           vm: PeriodListViewModel(budget: vm.budget, budgetService: budgetService))
                .presentationDetents([.large, .medium])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(appState.colorScheme)
        }
        .navigationDestination(for: PlanCategoryEntity.self) { category in
            CategoryView(vm: CategoryViewModel(
                category: category,
                period: vm.period,
                budget: vm.budget,
                currency: vm.currency,
                budgetService: budgetService,
                notificationService: notificationService)
            )
            .environmentObject(vm.formatters)
            .navigationTitle("Category")
            .preferredColorScheme(appState.colorScheme)
        }
        .navigationDestination(for: TransactionEntity.self) { transaction in
            TransactionView(vm: TransactionViewModel(
                transaction: transaction,
                budget: vm.budget,
                currency: vm.currency,
                budgetService: budgetService)
            )
            .environmentObject(vm.formatters)
            .navigationTitle("Transaction")
            .preferredColorScheme(appState.colorScheme)
        }
        .navigationDestination(for: CategoryNotificationsRef.self) { ref in
            NotificationsView(vm: NotificationsViewModel(
                categoryRef: ref,
                budget: vm.budget,
                budgetService: budgetService,
                notificationService: notificationService
            ))
            .environmentObject(vm.formatters)
            .navigationTitle("Reminders")
            .preferredColorScheme(appState.colorScheme)
        }
        .navigationDestination(for: NotificationEntity.self) { notification in
            NotificationView(vm: NotificationViewModel(
                notification: notification,
                notificationService: notificationService)
            )
                .environmentObject(vm.formatters)
                .navigationTitle("Reminder")
                .preferredColorScheme(appState.colorScheme)
        }
        .environmentObject(vm.formatters)
        .tint(Color.appLink)
        .onAppear {
            appState.showHelpPage(for: .mainPage, firstTime: true)
            vm.reloadBudget()
            analyticsService.logEvent(name: "budget_open")
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
            Text(vm.formatters.formatMonth(vm.period.startsAt))
        }
        .buttonStyle(.borderless)
        .tint(Color.appLink)
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
    
    let appState = AppState(bundle: bundle)
    appState.selectBudget(budget)
    
    do {
        var period = try budgetService.getOrCreateLastPeriod(budget)
        try dm.sync()
        return BudgetView(vm: BudgetViewModel(
            budget: budget, period: period, budgetService: bundle.budgetService, dataService: bundle.dataService
        ))
            .environmentObject(appState)
            .environmentObject(SubscriptionManager())
            .serviceBundle(bundle)
            .helpButtonVisible(true)
    } catch {
        print("Something went wrong \(error)")
        return Text("Something went wrong \(error)")
    }
}
