//
//  CategoryListView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 18.04.24.
//

import SwiftUI

struct CategoryCard: View {
    
    let category: CategoryData
    @ObservedObject var vm: BudgetViewModel
    
    var body: some View {
        FlexibleCardView {
            NavigationLink(value: category.entity) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: category.entity.iconNameValue)
                                .foregroundColor(category.entity.colorValue)
                            Text(category.entity.nameValue)
                        }
                        Text(vm.formatAmount(category.spendings.totalAmount))
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if category.entity.typeValue == .outcomePercent {
                            PlannedViewPercent()
                        } else if category.entity.typeValue == .outcomeFixed {
                            PlannedViewFixed()
                        }
                    }
                    CircularProgressView(progress: getPercentSpent(), lineWidth: 10) {
                        VStack {
                            Text(vm.formatPercent(getPercentSpentDecimal()))
                            Text("Spent")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    .frame(width: 85, height: 85)
                    .padding(.trailing, 5)
                }
                .tint(.black)
            }
        }
    }
    
    @ViewBuilder
    func PlannedViewPercent() -> some View {
        HStack {
            Image(systemName: "dollarsign.arrow.circlepath")
            Text(vm.formatPercent(category.entity.percentDecimal))
                .bold()
            Text("≈" + vm.formatAmount(getExpectedAmount()))
                .font(.caption)
        }
    }
    
    @ViewBuilder
    func PlannedViewFixed() -> some View {
        HStack {
            Image(systemName: "dollarsign.arrow.circlepath")
            Text(vm.formatAmount(category.entity.amountDecimal))
                .bold()
        }
    }
    
    func getPercentSpent() -> Double {
        return Double(truncating: getPercentSpentDecimal() as NSNumber)
    }
    
    func getPercentSpentDecimal() -> Decimal {
        if category.entity.typeValue == .outcomeFixed {
            if category.entity.amountDecimal <= 0 {
                return 1
            }
            
            return category.spendings.totalAmount / category.entity.amountDecimal
        }
        
        if category.entity.typeValue == .outcomePercent {
            if category.entity.percentDecimal <= 0 {
                return 1
            }
            
            let expectedAmount = vm.totalPlannedIncome * category.entity.percentDecimal
            return category.spendings.totalAmount / expectedAmount
        }
        
        return 1
    }
    
    func getExpectedAmount() -> Decimal {
        if category.entity.percentDecimal <= 0 {
            return 0
        }
        
        return vm.totalPlannedIncome * category.entity.percentDecimal
    }
    
}

struct CategoryListView: View {
    
    @ObservedObject var vm: BudgetViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(vm.categories) { category in
                    CategoryCard(category: category, vm: vm)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 15)
        .padding(.top, 15)
        .background(Color(uiColor: .secondarySystemBackground))
        .onAppear {
            vm.loadData(for: .categories)
        }
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
        category1.iconName = "case"
        category1.colorValue = .orange
        category1.typeValue = .outcomePercent
        category1.createdAt = Date()
        category1.budget = budget
        
        let category2 = PlanCategoryEntity(context: dm.viewContext)
        category2.id = UUID()
        category2.name = "Preview 2"
        category2.amount = 2000
        category2.percent = 0
        category2.iconName = "gym.bag"
        category2.colorValue = .green
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
        vm.period = try bundle.budgetService.getOrCreateLastPeriod(budget)
        vm.totalPlannedIncome = 1000
        
        return CategoryListView(vm: vm)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
