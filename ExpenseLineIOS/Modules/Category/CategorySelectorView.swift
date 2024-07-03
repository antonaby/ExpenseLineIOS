//
//  CategorySelectorView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 13.06.24.
//

import SwiftUI

struct CategorySelectorView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var category: PlanCategoryEntity?
    @Binding var categories: [PlanCategoryEntity]
    
    var body: some View {
        List {
            ForEach(categories) { ctg in
                Button {
                    category = ctg
                    dismiss()
                } label: {
                    HStack {
                        IconView(name: ctg.iconNameValue)
                        Text(ctg.nameValue)
                            .foregroundStyle(Color.appCardTextColor)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.appBackgroundSecondary)
            }
            Button {
                category = nil
                dismiss()
            } label: {
                Text("No Category")
                    .foregroundStyle(Color.appLink)
                    .frame(maxWidth: .infinity)
                    .font(.caption)
            }
            .listRowBackground(Color.appBackgroundSecondary)
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.appBackground)
        .scrollContentBackground(.hidden)
    }
    
}

#Preview {
    let bundle = ServiceBundle.preview
    let budgetService = bundle.budgetService
    
    let budget = budgetService.newBudgetEntity()
    budget.id = UUID()
    budget.name = "Preview"
    
    let category1 = budgetService.newCategoryEntity(budget)
    category1.id = UUID()
    category1.name = "Test"
    category1.typeValue = .income
    category1.iconName = "fi-gym"
    
    let category2 = budgetService.newCategoryEntity(budget)
    category2.id = UUID()
    category2.name = "Other"
    category2.typeValue = .outcomeFixed
    category2.iconName = "fl-book"
    
    let category3 = budgetService.newCategoryEntity(budget)
    category3.id = UUID()
    category3.name = "Thrid"
    category3.typeValue = .outcomePercent
    category3.iconName = "fi-house"
    
    return CategorySelectorView(
        category: .constant(nil),
        categories: .constant([category1, category2, category3]))
}
