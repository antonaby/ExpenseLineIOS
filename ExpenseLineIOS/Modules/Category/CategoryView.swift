//
//  CategoryView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 16.05.24.
//

import SwiftUI


struct CategoryView: View {
    
    @EnvironmentObject var budgetService: BudgetService
    
    @State var selectedTransaction: TransactionEntity? = nil
    @StateObject var vm: CategoryViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(vm.transactions) { transaction in
                        FlexibleCardView {
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
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .background(Color(uiColor: .secondarySystemBackground))
        .sheet(item: $selectedTransaction, onDismiss: onTransactionUpdated) { transaction in
            TransactionSheetView(
                vm: TransactionSheetViewModel(transaction: transaction,
                                              budget: vm.budget,
                                              currency: vm.currency,
                                              budgetService: budgetService))
                .presentationDetents([.medium])
        }
        .onAppear {
            vm.loadTransactions()
        }
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
