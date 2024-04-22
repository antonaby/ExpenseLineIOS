//
//  CategoryListView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 18.04.24.
//

import SwiftUI

struct CategoryCard: View {
    
    let category: CategoryInfo
    let currency: String
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text(category.entity.name ?? "")
                HStack(alignment: .firstTextBaseline) {
                    Text(category.spendings?.totalAmount ?? 0, format: .number.rounded(increment: 0.01))
                        .font(.largeTitle)
                    Text(currency)
                        .font(.title3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if category.entity.amount > 0 {
                    Text(category.entity.amount, format: .number.rounded(increment: 0.01))
                        .font(.caption)
                } else if category.entity.percent > 0 {
                    Text(category.entity.percent, format: .percent)
                        .font(.caption)
                }
            }
            .padding([.horizontal], 15)
            .padding([.vertical], 5)
        }
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
    }
}

struct CategoryListView: View {
    
    @ObservedObject var vm: BudgetViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(vm.getCategoryInfos()) { category in
                    CategoryCard(category: category, currency: vm.getCurrency())
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
    
    do {
        let category1 = PlanCategoryEntity(context: dm.viewContext)
        category1.id = UUID()
        category1.name = "Preview 1"
        category1.amount = 0
        category1.percent = 0.2
        category1.iconName = "preview"
        category1.typeValue = .outcomePercent
        category1.createdAt = Date()
        category1.budget = budget
        
        let category2 = PlanCategoryEntity(context: dm.viewContext)
        category2.id = UUID()
        category2.name = "Preview 2"
        category2.amount = 2000
        category2.percent = 0
        category2.iconName = "preview"
        category2.typeValue = .outcomeFixed
        category2.createdAt = Date()
        category2.budget = budget
        
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
        return CategoryListView(vm: vm)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
