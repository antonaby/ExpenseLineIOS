//
//  CategoryListView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 18.04.24.
//

import SwiftUI

struct CategoryCard: View {
    
    let category: CategoryInfo
    let currency: CurrencySymbol
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text(category.entity.name ?? "")
                HStack(alignment: .firstTextBaseline) {
                    Text("\(category.spendings?.totalAmount ?? 0)")
                        .font(.largeTitle)
                    Text(currency.code)
                        .font(.title3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if category.entity.amountDecimal > 0 {
                    Text("\(category.entity.amountDecimal)")
                        .font(.caption)
                } else if category.entity.percentDecimalFraction > 0 {
                    Text("\(category.entity.percentDecimalFraction)")
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
                    CategoryCard(category: category, currency: vm.currency)
                }
            }
            Spacer()
        }.background(Color(uiColor: .secondarySystemBackground))
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
            budgetService: budgetService,
            dataService: bundle.dataService
        )
        return CategoryListView(vm: vm)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
