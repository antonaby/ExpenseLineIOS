//
//  TransactionListView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 17.04.24.
//

import SwiftUI

struct TransactionListView: View {
    
    @EnvironmentObject var budgetService: BudgetService
    
    @StateObject var vm: TransactionListViewModel
    @State var selectedTransaction: TransactionEntity?
    
    var body: some View {
        VStack {
            ContentSizeCardView {
                TextField("Search", text: $vm.serachFilter)
            }
            .padding(.bottom, 5)
            ScrollView {
                LazyVStack {
                    ForEach(vm.transactions) { transaction in
                        TransactionCard(
                            vm: vm.parent,
                            transaction: transaction,
                            selectedTransaction: $selectedTransaction
                        ) { transaction in
                            vm.deleteTransaction(transaction)
                            vm.loadTransactions(filter: vm.serachFilter)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 15)
        .background(Color("BgDefault"))
        .sheet(item: $selectedTransaction, onDismiss: loadTransactions) { transaction in
            TransactionSheetView(
                vm: TransactionSheetViewModel(transaction: transaction,
                                              budget: vm.parent.budget,
                                              currency: vm.parent.currency,
                                              budgetService: budgetService))
                .presentationDetents([.medium])
        }
        .onAppear {
            vm.subscribe()
        }
        .onDisappear {
            vm.cancelAll()
        }
    }
    
    func loadTransactions() {
        vm.loadTransactions(filter: vm.serachFilter)
    }
    
}

#Preview {
    let bundle = ServiceBundle.preview
    
    let dm = bundle.databaseManager
    let budgetService = bundle.budgetService
    
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
   
    do {
        let category1 = PlanCategoryEntity(context: dm.viewContext)
        category1.id = UUID()
        category1.name = "Preview 1"
        category1.amount = 0
        category1.percent = 0.2
        category1.iconName = "fl-groceries"
        category1.typeValue = .outcomePercent
        category1.colorValue = .orange
        category1.createdAt = Date()
        category1.budget = budget
        
        let category2 = PlanCategoryEntity(context: dm.viewContext)
        category2.id = UUID()
        category2.name = "Preview 2"
        category2.amount = 2000
        category2.percent = 0
        category2.iconName = "fi-rent"
        category2.typeValue = .outcomeFixed
        category2.colorValue = .green
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
        
        let vm = BudgetViewModel(
            budget: budget,
            period: try bundle.budgetService.getOrCreateLastPeriod(budget),
            budgetService: bundle.budgetService,
            dataService: bundle.dataService
        )
        
        return TransactionListView(
            vm: TransactionListViewModel(parent: vm, budgetService: budgetService)
        )
            .serviceBundle(bundle)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
