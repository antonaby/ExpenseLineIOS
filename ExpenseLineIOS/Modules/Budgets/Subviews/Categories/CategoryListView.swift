//
//  CategoryListView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 18.04.24.
//

import SwiftUI

struct CategoryCard: View {
    
    @EnvironmentObject var formatters: FormattersHolder
    
    let category: CategoryData
    @ObservedObject var vm: BudgetViewModel
    
    var body: some View {
        FlexibleCardView {
            NavigationLink(value: category.entity) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            IconView(
                                name: category.entity.iconNameValue,
                                size: 45
                            )
                            .accessibilityLabel(category.entity.nameValue)
                            Text(category.entity.nameValue)
                                .foregroundStyle(Color.appCardTextColor)
                                .bold()
                        }
                        Text(formatters.formatAmount(category.spendings.totalAmount))
                            .foregroundStyle(Color.appCardTextColor)
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if category.entity.typeValue == .outcomePercent {
                            PlannedViewPercent()
                        } else if category.entity.typeValue == .outcomeFixed {
                            PlannedViewFixed()
                        }
                    }
                    CircularProgressView(
                        progress: getPercentSpent(),
                        color: Color.appLink,
                        fullColor: Color.appDestructiveLink,
                        lineWidth: 10) {
                        VStack {
                            Text(formatters.formatPercent(getPercentSpentDecimal()))
                            Text("Spent")
                                .font(.caption)
                        }
                        .foregroundColor(Color.appLinkInactive)
                    }
                    .frame(width: 85, height: 85)
                    .padding(.trailing, 5)
                    .accessibilityLabel("\(getPercentSpent())% Spent")
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
    
    @ViewBuilder
    func PlannedViewPercent() -> some View {
        HStack {
            Image(systemName: "dollarsign.arrow.circlepath")
            Text(formatters.formatPercent(category.entity.percentDecimal))
                .bold()
            Text("≈" + formatters.formatAmount(getExpectedAmount()))
                .font(.caption)
        }
        .foregroundStyle(Color.appLinkInactive)
    }
    
    @ViewBuilder
    func PlannedViewFixed() -> some View {
        HStack {
            Image(systemName: "dollarsign.arrow.circlepath")
            Text(formatters.formatAmount(category.entity.amountDecimal))
                .bold()
        }
        .foregroundStyle(Color.appLinkInactive)
    }
    
    func getPercentSpent() -> Double {
        return Double(truncating: getPercentSpentDecimal() as NSNumber)
    }
    
    func getPercentSpentDecimal() -> Decimal {
        if category.entity.typeValue == .outcomeFixed {
            if category.entity.amountDecimal <= 0 {
                return 0
            }
            
            return category.spendings.totalAmount / category.entity.amountDecimal
        }
        
        if category.entity.typeValue == .outcomePercent {
            if category.entity.percentDecimal <= 0 {
                return 0
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
    
    @StateObject var vm: CategoryListViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(vm.categories) { category in
                    CategoryCard(category: category, vm: vm.parent)
                }
                Color.clear
                    .frame(height: 70)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .background(Color.appBackground)
        .onAppear {
            vm.subscribe()
            vm.loadCategories()
        }
        .onDisappear {
            vm.cancelAll()
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
        let plannedCategory = budgetService.newCategoryEntity(budget)
        plannedCategory.typeValue = .income
        plannedCategory.amountDecimal = 1000
        
        let category1 = PlanCategoryEntity(context: dm.viewContext)
        category1.id = UUID()
        category1.name = "Preview 1"
        category1.amount = 0
        category1.percent = 0.2
        category1.iconName = "015-groceries"
        category1.typeValue = .outcomePercent
        category1.createdAt = Date()
        category1.budget = budget
        
        let category2 = PlanCategoryEntity(context: dm.viewContext)
        category2.id = UUID()
        category2.name = "Preview 2"
        category2.amount = 2000
        category2.percent = 0
        category2.iconName = "024-mortgage"
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
        transaction4.amountDecimal = 1800
        transaction4.createdAt = Date()
        transaction4.category = category2
        
        let parent = BudgetViewModel(
            budget: budget,
            period: try bundle.budgetService.getOrCreateLastPeriod(budget),
            budgetService: budgetService,
            dataService: bundle.dataService
        )
        
        let vm = CategoryListViewModel(parent: parent, budgetService: budgetService)
        return CategoryListView(vm: vm)
            .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
    } catch {
        return Text("Something went wrong \(error)")
    }
}
