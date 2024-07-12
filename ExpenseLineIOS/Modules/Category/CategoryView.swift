//
//  CategoryView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 16.05.24.
//

import SwiftUI


struct CategoryView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var budgetService: BudgetService
    @EnvironmentObject var analyticsService: AnalyticsService
    @EnvironmentObject var formatters: FormattersHolder
    
    @State var selectedTransaction: TransactionEntity? = nil
    @State var selectedCategory: PlanCategoryEntity? = nil
    @StateObject var vm: CategoryViewModel
    
    var body: some View {
        List {
            FlexibleCardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        IconView(
                            name: vm.category.iconNameValue,
                            size: 45
                        )
                        .accessibilityLabel(vm.category.nameValue)
                        Text(vm.category.nameValue)
                            .font(.title2)
                        Spacer()
                        Image(systemName: "pencil")
                            .foregroundColor(Color.appLink)
                            .frame(width: 50, height: 50, alignment: .topTrailing)
                            .padding([.top, .trailing], 10)
                            .onTapGesture {
                                selectedCategory = vm.category
                            }
                    }
                    HStack {
                        Text(formatters.formatAmount(vm.totalAmount))
                    }
                    .font(.largeTitle)
                    .bold()
                    ProgressView(progress: vm.percentSpent(), color: Color.appLink, fullColor: Color.appDestructiveLink)
                        .accessibilityLabel("\(vm.percentSpent())% Spent")
                        .accessibilityElement(children: .combine)
                    if vm.category.typeValue == .outcomePercent {
                        PlannedViewPercent()
                    } else {
                        PlannedViewFixed()
                    }
                }
            }
            .defaultListCard()
            FlexibleCardView {
                NavigationLink(value: CategoryNotificationsRef(category: vm.category)) {
                    if !vm.notifications.isEmpty {
                        ShortNotificationsListView(notifications: $vm.notifications, showCategory: false)
                    } else {
                        Text("Reminders")
                    }
                }
            }
            .defaultListCard()
            if !vm.transactions.isEmpty {
                ForEach(vm.transactions) { transaction in
                    FlexibleCardView {
                        NavigationLink(value: transaction) {
                            VStack(alignment: .leading) {
                                Text(transaction.nameValue)
                                Text(formatters.formatAmount(transaction.amountDecimal))
                                    .font(.title2)
                                    .bold()
                                Text(formatters.formatDate(transaction.createdAt))
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .tint(.black)
                        }
                    }
                    .defaultListCard()
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            vm.deleteTransaction(transaction)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(Color.appDestructiveLink)
                        Button {
                            selectedTransaction = transaction
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(Color.appLink)
                    }
                }
            } else {
                FlexibleCardView {
                    Text("No transactions")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .defaultListCard()
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground)
        .listStyle(.insetGrouped)
        .listRowSpacing(10)
        .sheet(item: $selectedTransaction, onDismiss: onTransactionUpdated) { transaction in
            TransactionSheetView(
                vm: TransactionSheetViewModel(transaction: transaction,
                                              budget: vm.budget,
                                              currency: vm.currency,
                                              budgetService: budgetService,
                                              analyticsService: analyticsService))
                .presentationDetents([.medium])
                .preferredColorScheme(appState.colorScheme)
        }
        .sheet(item: $selectedCategory) { category in
            EditCategorySheet(title: "Save",
                              vm: EditPlanCategorySheetViewModel(category, currencySymbol: vm.currency))
                .onUpdateCategory { category in
                    vm.updateCategory(category)
                    selectedCategory = nil
                }
                .onDeleteCategory { category in
                    vm.deleteCategory(category)
                    selectedCategory = nil
                    dismiss()
                }
                .onDismissCategory { category in
                    selectedCategory = nil
                }
                .presentationDetents([.medium])
                .preferredColorScheme(appState.colorScheme)
        }
        .onAppear {
            UICollectionView.appearance().contentInset.top = -20
            vm.loadTransactions()
            vm.loadNotifications()
        }
    }
    
    @ViewBuilder
    func PlannedViewPercent() -> some View {
        HStack {
            Image(systemName: "dollarsign.arrow.circlepath")
            Text(formatters.formatPercent(vm.category.percentDecimal))
                .bold()
            Text("≈" + formatters.formatAmount(vm.getPlannedAmountFromPercent()))
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(Color.appLinkInactive)
    }
    
    @ViewBuilder
    func PlannedViewFixed() -> some View {
        HStack{
            Image(systemName: "dollarsign.arrow.circlepath")
            Text(formatters.formatAmount(vm.category.amountDecimal))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(Color.appLinkInactive)
    }
    
    func onTransactionUpdated() {
        vm.loadTransactions()
    }
}

#Preview("Fixed") {
    let bundle = ServiceBundle.preview
    let budgetService = bundle.budgetService
    
    let budget = budgetService.newBudgetEntity()
    let category = budgetService.newCategoryEntity(budget)
    category.name = "Preview"
    category.typeValue = .outcomeFixed
    category.amountDecimal = 1000
    category.iconName = "fi-electricity"
    
    let transaction1 = budgetService.newTransactionEntity(budget)
    transaction1.name = "Transaction 1"
    transaction1.amountDecimal = 12
    transaction1.createdAt = Date()
    transaction1.category = category
    
    let transaction2 = budgetService.newTransactionEntity(budget)
    transaction2.name = "Transaction 2"
    transaction2.amountDecimal = 40
    transaction2.createdAt = Date()
    transaction2.category = category
    
    let transaction3 = budgetService.newTransactionEntity(budget)
    transaction3.name = "Transaction 3"
    transaction3.amountDecimal = 300
    transaction3.createdAt = Date()
    transaction3.category = category
    
    let notification1 = budgetService.newNotificationEntity(budget)
    notification1.name = "Preview 1"
    notification1.typeValue = .exact
    notification1.date = Date()
    notification1.enabled = true
    notification1.category = category
    
    let notification2 = budgetService.newNotificationEntity(budget)
    notification2.name = "Preview 2"
    notification2.typeValue = .daily
    notification2.date = Date()
    notification2.enabled = false
    notification2.category = category
    
    let notification3 = budgetService.newNotificationEntity(budget)
    notification3.name = "Preview 3"
    notification3.typeValue = .weekly
    notification3.date = Date()
    notification3.weekDaysArr = [1, 2, 3, 4, 5, 6, 7]
    notification3.enabled = true
    notification3.category = category

    let notification4 = budgetService.newNotificationEntity(budget)
    notification4.name = "Preview 4"
    notification4.typeValue = .nonotification
    notification4.enabled = false
    notification4.category = category
    
    do {
        let period = try budgetService.getOrCreateLastPeriod(budget)
        let vm = CategoryViewModel(
            category: category,
            period: period,
            budget: budget,
            currency: bundle.dataService.getCurrencySymbolOrDefault("en_US"),
            budgetService: budgetService,
            notificationService: bundle.notificationService,
            analyticsService: bundle.analyticsService
        )
        return CategoryView(vm: vm)
            .serviceBundle(bundle)
            .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
            .environmentObject(AppState(bundle: bundle))
    } catch {
        return Text("Something went wrong \(error)")
    }
}

#Preview("No transactions") {
    let bundle = ServiceBundle.preview
    let budgetService = bundle.budgetService
    
    let budget = budgetService.newBudgetEntity()
    let category = budgetService.newCategoryEntity(budget)
    category.name = "Preview"
    category.typeValue = .outcomeFixed
    category.amountDecimal = 1000
    category.iconName = "007-electricity"
    
    do {
        let period = try budgetService.getOrCreateLastPeriod(budget)
        let vm = CategoryViewModel(
            category: category,
            period: period,
            budget: budget,
            currency: bundle.dataService.getCurrencySymbolOrDefault("en_US"),
            budgetService: budgetService,
            notificationService: bundle.notificationService,
            analyticsService: bundle.analyticsService
        )
        return CategoryView(vm: vm)
            .serviceBundle(bundle)
            .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
            .environmentObject(AppState(bundle: bundle))
    } catch {
        return Text("Something went wrong \(error)")
    }
}

#Preview("Fixed Full") {
    let bundle = ServiceBundle.preview
    let budgetService = bundle.budgetService
    
    let budget = budgetService.newBudgetEntity()
    let category = budgetService.newCategoryEntity(budget)
    category.name = "Preview"
    category.typeValue = .outcomeFixed
    category.amountDecimal = 1000
    category.iconName = "007-electricity"
    
    let transaction1 = budgetService.newTransactionEntity(budget)
    transaction1.name = "Transaction 1"
    transaction1.amountDecimal = 12
    transaction1.createdAt = Date()
    transaction1.category = category
    
    let transaction2 = budgetService.newTransactionEntity(budget)
    transaction2.name = "Transaction 2"
    transaction2.amountDecimal = 40
    transaction2.createdAt = Date()
    transaction2.category = category
    
    let transaction3 = budgetService.newTransactionEntity(budget)
    transaction3.name = "Transaction 3"
    transaction3.amountDecimal = 2300
    transaction3.createdAt = Date()
    transaction3.category = category
    
    do {
        let period = try budgetService.getOrCreateLastPeriod(budget)
        let vm = CategoryViewModel(
            category: category,
            period: period,
            budget: budget,
            currency: bundle.dataService.getCurrencySymbolOrDefault("en_US"),
            budgetService: budgetService,
            notificationService: bundle.notificationService,
            analyticsService: bundle.analyticsService
        )
        return CategoryView(vm: vm)
            .serviceBundle(bundle)
            .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
            .environmentObject(AppState(bundle: bundle))
    } catch {
        return Text("Something went wrong \(error)")
    }
}

#Preview("Percent") {
    let bundle = ServiceBundle.preview
    let budgetService = bundle.budgetService
    
    let budget = budgetService.newBudgetEntity()
    
    let plannedCategory = budgetService.newCategoryEntity(budget)
    plannedCategory.typeValue = .income
    plannedCategory.amountDecimal = 1000
    
    let category = budgetService.newCategoryEntity(budget)
    category.name = "Preview"
    category.typeValue = .outcomePercent
    category.percentDecimal = 0.2
    category.iconName = "015-groceries"
    
    let transaction1 = budgetService.newTransactionEntity(budget)
    transaction1.name = "Transaction 1"
    transaction1.amountDecimal = 12
    transaction1.createdAt = Date()
    transaction1.category = category
    
    let transaction2 = budgetService.newTransactionEntity(budget)
    transaction2.name = "Transaction 2"
    transaction2.amountDecimal = 40
    transaction2.createdAt = Date()
    transaction2.category = category
    
    let transaction3 = budgetService.newTransactionEntity(budget)
    transaction3.name = "Transaction 3"
    transaction3.amountDecimal = 30
    transaction3.createdAt = Date()
    transaction3.category = category
    
    do {
        let period = try budgetService.getOrCreateLastPeriod(budget)
        let vm = CategoryViewModel(
            category: category,
            period: period,
            budget: budget,
            currency: bundle.dataService.getCurrencySymbolOrDefault("en_US"),
            budgetService: budgetService,
            notificationService: bundle.notificationService,
            analyticsService: bundle.analyticsService
        )
        return CategoryView(vm: vm)
            .serviceBundle(bundle)
            .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
            .environmentObject(AppState(bundle: bundle))
    } catch {
        return Text("Something went wrong \(error)")
    }
}
