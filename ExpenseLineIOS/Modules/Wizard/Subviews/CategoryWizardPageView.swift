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
                            Image(systemName: category.iconName ?? "questionmark.app.fill")
                            Text(category.name ?? "Unknown")
                            Spacer()
                            Text(vm.formatter.string(from: category.amountValue) ?? "0")
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

#Preview {
    let budget = BudgetEntity(context: DependencyResolver.preview.databaseManager().viewContext)
    let vm = BudgetWizardViewModel(budget, budgetService: DependencyResolver.preview.budgetService())
    return CategoryWizardPageView(
        vm: vm,
        name: "Preview",
        page: .fixed,
        type: .income
    )
}
