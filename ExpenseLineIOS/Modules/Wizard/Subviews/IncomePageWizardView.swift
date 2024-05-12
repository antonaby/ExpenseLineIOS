//
//  IncomePageWizardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 09.05.24.
//

import SwiftUI

struct IncomePageWizardView: View {
    
    @ObservedObject var vm: BudgetWizardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text("Income")
                    .modifier(FormTitleViewModifier.modifier)
                Text("Let's add your salry and other wages")
                    .modifier(FormTipViewModifier.modifier)
            }
            .padding(.bottom, 5)
            .padding(.horizontal, 20)
            Divider()
            CategoryListWizardView(vm: vm, types: [.income])
            BudgetShortSummaryView(vm: vm)
                .padding(.horizontal, 20)
        }
        .padding(.top, 5)
        .background(Color(uiColor: .secondarySystemBackground))
    }
}

#Preview {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
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
    category2.iconName = "globe"
    category2.budget = budget
    category2.amountDecimal = 1000000
    
    let vm = BudgetWizardViewModel(
        budget,
        budgetService: bundle.budgetService,
        dataService: bundle.dataService
    )
    
    return IncomePageWizardView(vm: vm)
}
