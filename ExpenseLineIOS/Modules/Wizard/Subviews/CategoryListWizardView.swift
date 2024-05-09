//
//  CategoryWizardPageView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 23.04.24.
//

import SwiftUI

struct CategoryListWizardView: View {
    
    @ObservedObject var vm: BudgetWizardViewModel
    
    let types: [CategoryType]
    
    var body: some View {
        List {
            ForEach(vm.categoriesForType(types)) { category in
                Button {
                    vm.selectCategory(category)
                } label: {
                    HStack {
                        Image(systemName: category.iconNameValue)
                            .foregroundColor(category.colorValue)
                            .frame(width: 20)
                        Text(category.nameValue)
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
                    vm.newCategory(types)
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                            .frame(width: 20)
                        Text("Add")
                    }
                    .foregroundColor(.black)
                }
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
    category1.typeValue = .outcomeFixed
    category1.colorValue = .green
    category1.iconName = "case"
    category1.budget = budget
    category1.amountDecimal = 1000
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Preview 2"
    category2.typeValue = .outcomeFixed
    category2.colorValue = .green
    category2.iconName = "globe"
    category2.budget = budget
    category2.amountDecimal = 1000000
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.id = UUID()
    category3.name = "Preview 3"
    category3.typeValue = .outcomePercent
    category3.colorValue = .green
    category3.iconName = "cup.and.saucer"
    category3.budget = budget
    category3.percentDecimalFraction = 15
    
    let category4 = PlanCategoryEntity(context: dm.viewContext)
    category4.id = UUID()
    category4.name = "Preview 4"
    category4.typeValue = .outcomePercent
    category4.colorValue = .green
    category4.iconName = "takeoutbag.and.cup.and.straw"
    category4.budget = budget
    category4.percentDecimalFraction = 20
    
    let vm = BudgetWizardViewModel(
        budget,
        budgetService: DependencyResolver.preview.budgetService(),
        dataService: DependencyResolver.preview.dataService()
    )
    
    return CategoryListWizardView(
        vm: vm,
        types: [.outcomeFixed, .outcomePercent]
    )
}

#Preview("Amount EUR") {
    let dm = DependencyResolver.preview.databaseManager()
    let budget = BudgetEntity(context: dm.viewContext)
    budget.currency = "de_DE"
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
    category1.name = "Preview 1"
    category1.typeValue = .outcomeFixed
    category1.colorValue = .green
    category1.iconName = "case"
    category1.budget = budget
    category1.amountDecimal = 1000
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Preview 2"
    category2.typeValue = .outcomeFixed
    category2.colorValue = .green
    category2.iconName = "case"
    category2.budget = budget
    category2.amountDecimal = 1000000
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.id = UUID()
    category3.name = "Preview 3"
    category3.typeValue = .outcomePercent
    category3.colorValue = .green
    category3.iconName = "cup.and.saucer"
    category3.budget = budget
    category3.percentDecimalFraction = 15
    
    let category4 = PlanCategoryEntity(context: dm.viewContext)
    category4.id = UUID()
    category4.name = "Preview 4"
    category4.typeValue = .outcomePercent
    category4.colorValue = .green
    category4.iconName = "takeoutbag.and.cup.and.straw"
    category4.budget = budget
    category4.percentDecimalFraction = 20

    let vm = BudgetWizardViewModel(
        budget,
        budgetService: DependencyResolver.preview.budgetService(),
        dataService: DependencyResolver.preview.dataService()
    )
    
    return CategoryListWizardView(
        vm: vm,
        types: [.outcomeFixed, .outcomePercent]
    )
}

