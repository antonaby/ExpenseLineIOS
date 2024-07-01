//
//  CategoryWizardPageView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 23.04.24.
//

import SwiftUI

struct CategoryListWizardView: View {
    
    @EnvironmentObject var subscriptionService: SubscriptionService
    @EnvironmentObject var appState: AppState
    
    @ObservedObject var vm: BudgetWizardViewModel
    
    let type: CategoryType
    
    var body: some View {
        List {
            ForEach(vm.categoriesForType([type])) { category in
                Button {
                    vm.selectCategory(category)
                } label: {
                    FlexibleCardView {
                        HStack {
                            IconView(
                                name: category.iconNameValue,
                                color: category.colorValue,
                                size: 45
                            )
                            Text(category.nameValue)
                            Spacer()
                            if category.typeValue == .outcomePercent {
                                HStack {
                                    Text(vm.formatters.formatPercent(category.percentDecimal))
                                    Text("≈" + formatPercentAmount(category))
                                        .font(.caption)
                                        .foregroundColor(Color.appLinkInactive)
                                }
                            } else {
                                Text(vm.formatters.formatAmount(category.amountDecimal))
                            }
                        }
                        .foregroundStyle(Color.appCardTextColor)
                    }
                }
                .defaultListCard()
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        vm.deleteCategory(category)
                    } label: {
                        Label("delete", systemImage: "trash.fill")
                    }
                    .tint(Color.appDestructiveLink)
                }
            }
            HStack {
                Button {
                    if subscriptionService.checkMaxCategoryCount(vm.budget) {
                        vm.newCategory(type)
                    } else {
                        appState.showPaywall()
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .foregroundColor(Color.appLink)
                    .frame(maxWidth: .infinity)
                    .font(.title3)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.appBackgroundSecondary)
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground)
        .listStyle(.insetGrouped)
        .listRowSpacing(10)
        .onAppear {
            UICollectionView.appearance().contentInset.top = -20
        }
    }
    
    func formatPercentAmount(_ category: PlanCategoryEntity) -> String {
        let amount = category.percentDecimal * vm.calculateTotalIncome()
        return vm.formatters.formatAmount(amount)
    }
    
}

#Preview("Amount USD") {
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
    
    return CategoryListWizardView(
        vm: vm,
        type: .outcomeFixed
    )
    .serviceBundle(bundle)
    .environmentObject(AppState(bundle: bundle))
}

#Preview("Amount EUR") {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.currency = "de_DE"
    
    let incomeCategory = bundle.budgetService.newCategoryEntity(budget)
    incomeCategory.typeValue = .income
    incomeCategory.amountDecimal = 5000
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
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
    
    return CategoryListWizardView(
        vm: vm,
        type: .outcomePercent
    )
    .serviceBundle(bundle)
    .environmentObject(AppState(bundle: bundle))
}

