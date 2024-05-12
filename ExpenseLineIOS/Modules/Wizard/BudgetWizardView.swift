//
//  BudgetWizardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.04.24.
//

import SwiftUI

enum WizzardPage: Int, Identifiable, CaseIterable {
    case base = 0
    case income
    case outcome
    
    var id: Self { self }
}

struct BudgetWizardView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var currentPage: WizzardPage = .base
    
    @StateObject var vm: BudgetWizardViewModel
    let editMode: Bool
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    if currentPage.rawValue != 0 {
                        Button {
                            previousPage()
                        } label: {
                            Label("Back", systemImage: "chevron.backward")
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    ToolButton(icon: "x.circle", color: .gray) {
                        vm.rollback()
                        dismiss()
                    }
                    .font(.title2)
                }
                HStack(spacing: 20) {
                    ForEach(WizzardPage.allCases) { page in
                        PageIconView(page)
                    }
                }
            }
            .padding([.horizontal], 10)
            WizardPageView()
                .padding(.bottom, 5)
            HStack {
                if (editMode && currentPage != .outcome) || currentPage == .outcome  {
                    WizzardNextButton("Save") {
                        vm.save()
                        dismiss()
                    }
                    .disabled(!vm.isFormValid)
                }
                if currentPage != .outcome {
                    WizzardNextButton("Next") {
                        nextPage()
                    }
                }
                
            }
            .padding([.horizontal], 20)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .sheet(item: $vm.selectedCategory) { category in
            EditCategorySheet(title: "Save",
                              vm: EditPlanCategorySheetViewModel(category, currencySymbol: vm.currency))
                .onUpdateCategory { category in
                    vm.updateCategory(category)
                }
                .onDeleteCategory { category in
                    vm.deleteCategory(category)
                }
                .onDismissCategory { category in
                    vm.dismissCategory(category)
                }
                .presentationDetents([.medium])
        }
        .onDisappear {
            vm.cancelAll()
        }
    }
    
    @ViewBuilder
    func WizardPageView() -> some View {
        switch currentPage {
        case .base:
            MainWizardPageView(vm: vm)
        case .income:
            IncomePageWizardView(vm: vm)
        case .outcome:
            OutcomePageWizardView(vm: vm)
        }
    }
    
    @ViewBuilder
    func PageIconView(_ page: WizzardPage) -> some View {
        Button {
            currentPage = page
        } label: {
            FlexibleCardView(color: currentPage == page ? .green : .white) {
                Image(systemName: getIconForPage(page))
                    .foregroundColor(currentPage == page ? .white : .black)
                    .font(.caption)
                    .bold()
            }
            .frame(width: 30, height: 30)
        }
    }
    
    func getIconForPage(_ page: WizzardPage) -> String {
        switch page {
        case .base:
            return "square.and.pencil"
        case .income:
            return "case"
        case .outcome:
            return "list.bullet"
        }
    }
    
    func nextButtonCaption() -> String {
        if currentPage == .outcome && editMode {
            return "Save"
        }
        
        return currentPage == .outcome ? "Create" : "Next"
    }
    
    func nextPage() {
        let nextValue = currentPage.rawValue + 1
        if  nextValue <= WizzardPage.outcome.rawValue {
            currentPage = WizzardPage(rawValue: nextValue) ?? .base
        }
    }
    
    func previousPage() {
        let previousValue = currentPage.rawValue - 1
        if previousValue >= 0 {
            currentPage = WizzardPage(rawValue: previousValue) ?? .base
        }
    }
    
}

#Preview("New Budget") {
    let bundle = ServiceBundle.preview
    let vm = BudgetWizardViewModel(
        bundle.budgetService.newBudgetEntity(),
        budgetService: bundle.budgetService,
        dataService: bundle.dataService
    )
    
    return BudgetWizardView(vm: vm, editMode: false)
}

#Preview("Edit Budget") {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.name = "Preview"
    budget.currency = "en_US"
    budget.planTypeValue = .mountly
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
    category1.id = UUID()
    category1.name = "Preview 1"
    category1.typeValue = .outcomeFixed
    category1.colorValue = .pink
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
    category3.colorValue = .brown
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
    
    let category5 = PlanCategoryEntity(context: dm.viewContext)
    category5.id = UUID()
    category5.name = "Preview 1"
    category5.typeValue = .income
    category5.colorValue = .yellow
    category5.iconName = "case"
    category5.budget = budget
    category5.amountDecimal = 1000
    
    let category6 = PlanCategoryEntity(context: dm.viewContext)
    category6.id = UUID()
    category6.name = "Preview 2"
    category6.typeValue = .income
    category6.colorValue = .orange
    category6.iconName = "globe"
    category6.budget = budget
    category6.amountDecimal = 1000000
    
    let vm = BudgetWizardViewModel(
        budget,
        budgetService: bundle.budgetService,
        dataService: bundle.dataService
    )
    
    return BudgetWizardView(vm: vm, editMode: true)
}
