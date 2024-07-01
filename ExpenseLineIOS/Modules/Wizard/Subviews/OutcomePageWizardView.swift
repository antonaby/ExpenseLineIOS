//
//  OutcomePageWizardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 09.05.24.
//

import SwiftUI

struct OutcomePageWizardView: View {
    
    @EnvironmentObject var appState: AppState
    
    @ObservedObject var vm: BudgetWizardViewModel
    var type: CategoryType
    var helpPage: HelpPage
    
    var body: some View {
        VStack {
            CategoryListWizardView(vm: vm, type: type)
            BudgetShortSummaryView(vm: vm)
                .padding(.horizontal, 20)
        }
        .background(Color.appBackground)
        .onAppear {
            appState.showHelpPage(for: helpPage, firstTime: true)
        }
    }
}

#Preview("Fixed") {
    let bundle = ServiceBundle.preview
    
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.currency = "en_US"
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
    category1.id = UUID()
    category1.name = "Preview 1"
    category1.typeValue = .outcomeFixed
    category1.colorValue = .green
    category1.iconName = "024-mortgage"
    category1.budget = budget
    category1.amountDecimal = 1000
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Preview 2"
    category2.typeValue = .outcomeFixed
    category2.colorValue = .green
    category2.iconName = "007-electricity"
    category2.budget = budget
    category2.amountDecimal = 1000000
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.id = UUID()
    category3.name = "Preview 3"
    category3.typeValue = .outcomePercent
    category3.colorValue = .green
    category3.iconName = "015-groceries"
    category3.budget = budget
    category3.percentDecimalFraction = 15
    
    let category4 = PlanCategoryEntity(context: dm.viewContext)
    category4.id = UUID()
    category4.name = "Preview 4"
    category4.typeValue = .outcomePercent
    category4.colorValue = .green
    category4.iconName = "005-coffee"
    category4.budget = budget
    category4.percentDecimalFraction = 20
    
    let vm = BudgetWizardViewModel(
        budget,
        budgetService: bundle.budgetService,
        dataService: bundle.dataService,
        notificationService: bundle.notificationService
    )
    
    return OutcomePageWizardView(vm: vm, type: .outcomeFixed, helpPage: .incomeWizard)
        .serviceBundle(bundle)
        .environmentObject(AppState(bundle: bundle))
}

#Preview("Flexible") {
    let bundle = ServiceBundle.preview
    
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.currency = "en_US"
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
    category1.id = UUID()
    category1.name = "Preview 1"
    category1.typeValue = .outcomeFixed
    category1.colorValue = .green
    category1.iconName = "024-mortgage"
    category1.budget = budget
    category1.amountDecimal = 1000
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Preview 2"
    category2.typeValue = .outcomeFixed
    category2.colorValue = .green
    category2.iconName = "007-electricity"
    category2.budget = budget
    category2.amountDecimal = 1000000
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.id = UUID()
    category3.name = "Preview 3"
    category3.typeValue = .outcomePercent
    category3.colorValue = .green
    category3.iconName = "015-groceries"
    category3.budget = budget
    category3.percentDecimalFraction = 15
    
    let category4 = PlanCategoryEntity(context: dm.viewContext)
    category4.id = UUID()
    category4.name = "Preview 4"
    category4.typeValue = .outcomePercent
    category4.colorValue = .green
    category4.iconName = "005-coffee"
    category4.budget = budget
    category4.percentDecimalFraction = 20
    
    let vm = BudgetWizardViewModel(
        budget,
        budgetService: bundle.budgetService,
        dataService: bundle.dataService,
        notificationService: bundle.notificationService
    )
    
    return OutcomePageWizardView(vm: vm, type: .outcomePercent, helpPage: .incomeWizard)
        .serviceBundle(bundle)
        .environmentObject(AppState(bundle: bundle))
}
