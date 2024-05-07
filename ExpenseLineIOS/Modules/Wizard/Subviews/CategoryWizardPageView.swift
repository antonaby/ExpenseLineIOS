//
//  CategoryWizardPageView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 23.04.24.
//

import SwiftUI

struct CategoryWizardPageView: View {
    
    @ObservedObject var vm: BudgetWizardViewModel
    
    let name: String
    let page: WizzardPage
    let type: CategoryType
    
    var body: some View {
        Form {
            Section {
                ForEach(vm.categoriesForType(type)) { category in
                    Button {
                        vm.selectCategory(category)
                    } label: {
                        HStack {
                            Image(systemName: category.iconName ?? "questionmark")
                                .foregroundColor(category.colorValue)
                            Text(category.name ?? "Unknown")
                            Spacer()
                            if category.typeValue == .outcomePercent {
                                Text(vm.percnetFormatter.string(from: category.percentValue) ?? "0")
                            } else {
                                Text(vm.currencyFormatter.string(from: category.amountValue) ?? "0")
                            }
                        }
                        .foregroundColor(.black)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            vm.deleteCategory(category)
                        } label: {
                            Label("delete", systemImage: "trash.fill")
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                HStack {
                    Button {
                        vm.newCategory(page)
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            } header: {
                Text(name)
            }
        }
    }
}

#Preview("Amount USD") {
    let dm = DependencyResolver.preview.databaseManager()
    let budget = BudgetEntity(context: dm.viewContext)
    budget.currency = "en_US"
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
    category1.id = UUID()
    category1.name = "Preview 1"
    category1.typeValue = .income
    category1.colorValue = .green
    category1.iconName = "case"
    category1.budget = budget
    category1.amountDecimal = 1000
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Preview 2"
    category2.typeValue = .income
    category2.colorValue = .green
    category2.iconName = "case"
    category2.budget = budget
    category2.amountDecimal = 1000000
    
    let vm = BudgetWizardViewModel(
        budget,
        budgetService: DependencyResolver.preview.budgetService(),
        dataService: DependencyResolver.preview.dataService()
    )
    
    return CategoryWizardPageView(
        vm: vm,
        name: "Preview",
        page: .fixed,
        type: .income
    )
}

#Preview("Amount EUR") {
    let dm = DependencyResolver.preview.databaseManager()
    let budget = BudgetEntity(context: dm.viewContext)
    budget.currency = "de_DE"
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
    category1.name = "Preview 1"
    category1.typeValue = .income
    category1.colorValue = .green
    category1.iconName = "case"
    category1.budget = budget
    category1.amountDecimal = 1000
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Preview 2"
    category2.typeValue = .income
    category2.colorValue = .green
    category2.iconName = "case"
    category2.budget = budget
    category2.amountDecimal = 1000000
    
    let vm = BudgetWizardViewModel(
        budget,
        budgetService: DependencyResolver.preview.budgetService(),
        dataService: DependencyResolver.preview.dataService()
    )
    
    return CategoryWizardPageView(
        vm: vm,
        name: "Preview",
        page: .fixed,
        type: .income
    )
}

#Preview("Amount Percent") {
    let dm = DependencyResolver.preview.databaseManager()
    let budget = BudgetEntity(context: dm.viewContext)
    budget.currency = "de_DE"
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
    category1.name = "Preview 1"
    category1.typeValue = .outcomePercent
    category1.colorValue = .green
    category1.iconName = "case"
    category1.budget = budget
    category1.percentDecimalFraction = 20
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Preview 2"
    category2.typeValue = .outcomePercent
    category2.colorValue = .green
    category2.iconName = "case"
    category2.budget = budget
    category2.percentDecimalFraction = 15
    
    let vm = BudgetWizardViewModel(
        budget,
        budgetService: DependencyResolver.preview.budgetService(),
        dataService: DependencyResolver.preview.dataService()
    )
    
    return CategoryWizardPageView(
        vm: vm,
        name: "Preview",
        page: .dynamic,
        type: .outcomePercent
    )
}
