//
//  TransactionListView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 17.04.24.
//

import SwiftUI

struct TransactionCard: View {
    
    let transaction: TransactionEntity
    let currency: String
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text(transaction.category?.name ?? "")
                    .font(.caption)
                Text(transaction.name ?? "")
                HStack(alignment: .firstTextBaseline) {
                    Text(transaction.amount, format: .number.rounded(increment: 0.01))
                        .font(.largeTitle)
                    Text(currency)
                        .font(.title3)
                }.frame(maxWidth: .infinity, alignment: .leading)
                Text(transaction.createdAt ?? Date(), format: .dateTime)
                    .font(.caption)
            }
            .padding([.horizontal], 15)
            .padding([.vertical], 5)
        }
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
    }
}

struct TransactionListView: View {
    
    @ObservedObject var vm: BudgetViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(vm.getAllTransactions()) { transaction in
                    TransactionCard(transaction: transaction, currency: vm.getCurrency())
                }
            }
            Spacer()
        }.background(Color(uiColor: .secondarySystemBackground))
    }
}

#Preview {
    let dm = DependencyResolver.preview.databaseManager()
    let budgetService = DependencyResolver.preview.budgetService()
    
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
   
    dm.save()
    
    do {
        let category1 = PlanCategoryEntity(context: dm.viewContext)
        category1.id = UUID()
        category1.name = "Preview 1"
        category1.amount = 0
        category1.percent = 0.2
        category1.iconName = "preview"
        category1.typeValue = .outcomePercent
        category1.createdAt = Date()
        
        let category2 = PlanCategoryEntity(context: dm.viewContext)
        category2.id = UUID()
        category2.name = "Preview 2"
        category2.amount = 2000
        category2.percent = 0
        category2.iconName = "preview"
        category2.typeValue = .outcomeFixed
        category2.createdAt = Date()
        
        dm.save()
        
        try budgetService.createTransaction(
            Transaction(id: UUID(), name: "Test 1", amount: 15, createdAt: Date()),
            category: category1,
            budget: budget
        )
        
        try budgetService.createTransaction(
            Transaction(id: UUID(), name: "Test 2", amount: 40, createdAt: Date()),
            category: category1,
            budget: budget
        )
        
        try budgetService.createTransaction(
            Transaction(id: UUID(), name: "Test 3", amount: 300, createdAt: Date()),
            category: category2,
            budget: budget
        )
        
        try budgetService.createTransaction(
            Transaction(id: UUID(), name: "Test 4", amount: 800, createdAt: Date()),
            category: category2,
            budget: budget
        )
        
        let vm = try DependencyResolver.preview.budgetViewModel(budget)
        vm.currentDailyOutcome = 20
        vm.plannedDailyOutcome = 100
        return TransactionListView(vm: vm)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
