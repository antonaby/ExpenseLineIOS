//
//  CategoryView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 16.05.24.
//

import SwiftUI


struct CategoryView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var budgetService: BudgetService
    
    @State var selectedTransaction: TransactionEntity? = nil
    @State var selectedCategory: PlanCategoryEntity? = nil
    @StateObject var vm: CategoryViewModel
    
    var body: some View {
        VStack {
            ContentSizeCardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: vm.category.iconNameValue)
                            .foregroundColor(vm.category.colorValue)
                            .font(.title)
                        Text(vm.category.nameValue)
                            .font(.title2)
                        Spacer()
                        Button {
                            selectedCategory = vm.category
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.green)
                        }
                    }
                    HStack {
                        Text(vm.formatAmount(vm.totalAmount))
                    }
                    .font(.largeTitle)
                    .bold()
                    ProgressView(percent: vm.percentSpent())
                    if vm.category.typeValue == .outcomePercent {
                        PlannedViewPercent()
                    } else {
                        PlannedViewFixed()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 10)
            Text("Transactions")
                .bold()
            List(vm.transactions) { transaction in
                VStack(alignment: .leading) {
                    HStack {
                        Text(transaction.nameValue)
                        Spacer()
                        Button {
                            selectedTransaction = transaction
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                        .tint(.green)
                    }
                    Text(vm.formatAmount(transaction.amountDecimal))
                        .font(.title2)
                        .bold()
                    Text(vm.formatDate(transaction.createdAt))
                        .font(.caption)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        vm.deleteTransaction(transaction)
                    } label: {
                        Label("delete", systemImage: "trash.fill")
                    }
                }
            }
            .listStyle(.plain)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .sheet(item: $selectedTransaction, onDismiss: onTransactionUpdated) { transaction in
            TransactionSheetView(
                vm: TransactionSheetViewModel(transaction: transaction,
                                              budget: vm.budget,
                                              currency: vm.currency,
                                              budgetService: budgetService))
                .presentationDetents([.medium])
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
        }
        .onAppear {
            vm.loadTransactions()
        }
    }
     
    @ViewBuilder
    func PlannedViewPercent() -> some View {
        VStack(alignment: .trailing) {
            HStack {
                Text("Planned:")
                Text(vm.formatPercent(vm.category.percentDecimal))
                    .bold()
            }
            Text("≈" + vm.formatAmount(vm.getPlannedAmountFromPercent()))
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    @ViewBuilder
    func PlannedViewFixed() -> some View {
        Text("Planned: " + vm.formatAmount(vm.category.amountDecimal))
            .frame(maxWidth: .infinity, alignment: .trailing)
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
    category.iconName = "cup.and.saucer"
    category.colorValue = .orange
    
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
    
    do {
        let period = try budgetService.getOrCreateLastPeriod(budget)
        let vm = CategoryViewModel(
            category: category,
            period: period,
            budget: budget,
            currency: bundle.dataService.getCurrencySymbolOrDefault("en_US"),
            budgetService: budgetService
        )
        return CategoryView(vm: vm)
            .serviceBundle(bundle)
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
    category.iconName = "cup.and.saucer"
    category.colorValue = .orange
    
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
            budgetService: budgetService
        )
        return CategoryView(vm: vm)
            .serviceBundle(bundle)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
