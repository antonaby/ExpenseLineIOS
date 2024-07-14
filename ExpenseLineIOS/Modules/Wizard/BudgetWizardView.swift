//
//  BudgetWizardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.04.24.
//

import SwiftUI

struct BudgetAction {
    
    typealias Action = (BudgetEntity) -> Void
    let action: Action
    
    func callAsFunction(_ budget: BudgetEntity) {
        action(budget)
    }
    
}

struct UpdateBudgetActionKey: EnvironmentKey {
    
    static var defaultValue: BudgetAction?
    
}

struct DeleteBudgetActionKey: EnvironmentKey {
    
    static var defaultValue: BudgetAction?
    
}

struct DismissBudgetActionKey: EnvironmentKey {
    
    static var defaultValue: BudgetAction?
    
}

extension EnvironmentValues {
    
    var updateBudget: BudgetAction? {
       get { self[UpdateBudgetActionKey.self] }
       set { self[UpdateBudgetActionKey.self] = newValue }
    }
    
    var deleteBudget: BudgetAction? {
        get { self[DeleteBudgetActionKey.self] }
        set { self[DeleteBudgetActionKey.self] = newValue }
    }
    
    var dismissBudget: BudgetAction? {
        get { self[DismissBudgetActionKey.self] }
        set { self[DismissBudgetActionKey.self] = newValue }
    }
    
}

extension View {
    
    func onUpdateBudget(_ action: @escaping BudgetAction.Action) -> some View {
        self.environment(\.updateBudget, BudgetAction(action: action))
    }
    
    func onDeleteBudget(_ action: @escaping BudgetAction.Action) -> some View {
        self.environment(\.deleteBudget, BudgetAction(action: action))
    }
    
    func onDismissBudget(_ action: @escaping BudgetAction.Action) -> some View {
        self.environment(\.dismissBudget, BudgetAction(action: action))
    }
    
}


enum WizzardPage: Int, Identifiable, CaseIterable {
    case base = 0
    case income
    case outcomeFixed
    case outcomeFlexible
    
    var id: Self { self }
}

struct BudgetWizardView: View {
    
    @EnvironmentObject var analyticsService: AnalyticsService
    @EnvironmentObject var appState: AppState
    
    @Environment(\.updateBudget) private var update
    @Environment(\.dismissBudget) private var dismiss
    
    @State var currentPage: WizzardPage = .base
    
    @StateObject var vm: BudgetWizardViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 10) {
                ForEach(WizzardPage.allCases) { page in
                    PageIconView(page)
                }
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .leading) {
                Button {
                    if currentPage.rawValue != 0 {
                        previousPage()
                    } else {
                        vm.rollback()
                        dismiss?(vm.budget)
                    }
                } label: {
                    Label("Back", systemImage: "chevron.backward")
                        .foregroundColor(Color.appLink)
                        .padding(.leading, 10)
                }
            }
            .overlay(alignment: .trailing) {
                ToolButton(icon: "x.circle", color: Color.appDestructiveLink) {
                    vm.rollback()
                    dismiss?(vm.budget)
                }
                .font(.title2)
                .padding(.trailing, 10)
                .accessibilityLabel("Close")
                .accessibilityElement(children: .combine)
            }
            HStack {
                Text(getPageTitle(currentPage))
                    .modifier(FormTitleViewModifier.modifier)
                HelpButton {
                    appState.showHelpPage(for: getHelpPage())
                }
            }
            .padding(.horizontal, 20)
            WizardPageView()
            Group {
                if vm.editMode {
                    EditModeControlView()
                } else {
                    CreateModeControlView()
                }
            }
            .padding(.horizontal, 20)
        }
        .background(Color.appBackground)
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
                .preferredColorScheme(appState.colorScheme)
        }
        .onDisappear {
            vm.cancelAll()
        }
    }
    
    @ViewBuilder
    func EditModeControlView() -> some View {
        HStack {
            WizzardNextButton {
                vm.save()
                analyticsService.logEvent(name: AnalyticsService.BUDGET_EDITED)
                update?(vm.budget)
            } content: {
                Text("Save")
                    .modifier(WizardButtonContentViewModifier.modifier)
            }
            .disabled(!vm.isBudgetValid())
            .accessibilityLabel("Save")
            .accessibilityElement(children: .combine)
            WizzardNextButton {
                nextPage()
            } content: {
                Image(systemName: "chevron.right")
                    .frame(width: 35, height: 35)
                    .font(.headline)
            }
            .disabled(currentPage == .outcomeFlexible)
            .accessibilityLabel("Next")
            .accessibilityElement(children: .combine)
        }
    }
    
    @ViewBuilder
    func CreateModeControlView() -> some View {
        WizzardNextButton {
            if currentPage != .outcomeFlexible {
                nextPage()
            } else {
                vm.save()
                analyticsService.logEvent(name: AnalyticsService.BUDGET_NEW_CREATED)
                update?(vm.budget)
            }
        } content: {
            if currentPage != .outcomeFlexible {
                Text("Next")
                    .modifier(WizardButtonContentViewModifier.modifier)
            } else {
                Text("Save")
                    .modifier(WizardButtonContentViewModifier.modifier)
            }
        }
        .disabled(!vm.isPageValid(currentPage))
    }
 
    @ViewBuilder
    func WizardPageView() -> some View {
        switch currentPage {
        case .base:
            MainWizardPageView(vm: vm)
        case .income:
            OutcomePageWizardView(vm: vm, type: .income, helpPage: .incomeWizard)
        case .outcomeFixed:
            OutcomePageWizardView(vm: vm, type: .outcomeFixed, helpPage: .fixedOutcomeWizard)
        case .outcomeFlexible:
            OutcomePageWizardView(vm: vm, type: .outcomePercent, helpPage: .flexibleOutcomeWizard)
        }
    }
    
    @ViewBuilder
    func PageIconView(_ page: WizzardPage) -> some View {
        Button {
            currentPage = page
        } label: {
            FlexibleCardView(cornerRadius: 7, color: currentPage == page ? Color.appLink : Color.appBackground) {
                Image(systemName: getIconForPage(page))
                    .foregroundColor(currentPage == page ? Color.appButtonTextColor : Color.appCardTextColor)
                    .font(.caption)
                    .bold()
                    .accessibilityLabel(getPageTitle(page))
            }
            .frame(width: 30, height: 30)
        }
    }
    
    func getIconForPage(_ page: WizzardPage) -> String {
        switch page {
        case .base:
            return "pencil"
        case .income:
            return "case"
        case .outcomeFixed:
            return "house"
        case .outcomeFlexible:
            return "takeoutbag.and.cup.and.straw"
        }
    }
    
    func getPageTitle(_ page: WizzardPage) -> String {
        switch page {
        case .base:
            return "Budget"
        case .income:
            return "Earnings"
        case .outcomeFixed:
            return "Fixed Expenses"
        case .outcomeFlexible:
            return "Flexible Expenses"
        }
    }
    
    func getHelpPage() -> HelpPage {
        switch currentPage {
        case .income:
            return .incomeWizard
        case .outcomeFixed:
            return .fixedOutcomeWizard
        case .outcomeFlexible:
            return .flexibleOutcomeWizard
        default:
            return .mainWizard
        }
    }
    
    func nextPage() {
        let nextValue = currentPage.rawValue + 1
        if  nextValue <= WizzardPage.outcomeFlexible.rawValue {
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
    let budget = bundle.budgetService.newBudgetEntity()
    budget.isNew = true
    
    let vm = BudgetWizardViewModel(
        budget,
        budgetService: bundle.budgetService,
        dataService: bundle.dataService,
        notificationService: bundle.notificationService,
        analyticsService: bundle.analyticsService
    )
    
    return BudgetWizardView(vm: vm)
        .serviceBundle(bundle)
        .environmentObject(AppState(bundle: bundle))
}

#Preview("Edit Budget") {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.name = "Preview"
    budget.currency = "en_US"
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
    category1.id = UUID()
    category1.name = "Preview 1"
    category1.typeValue = .outcomeFixed
    category1.iconName = "case"
    category1.budget = budget
    category1.amountDecimal = 1000
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Preview 2"
    category2.typeValue = .outcomeFixed
    category2.iconName = "globe"
    category2.budget = budget
    category2.amountDecimal = 1000000
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.id = UUID()
    category3.name = "Preview 3"
    category3.typeValue = .outcomePercent
    category3.iconName = "cup.and.saucer"
    category3.budget = budget
    category3.percentDecimalFraction = 15
    
    let category4 = PlanCategoryEntity(context: dm.viewContext)
    category4.id = UUID()
    category4.name = "Preview 4"
    category4.typeValue = .outcomePercent
    category4.iconName = "takeoutbag.and.cup.and.straw"
    category4.budget = budget
    category4.percentDecimalFraction = 20
    
    let category5 = PlanCategoryEntity(context: dm.viewContext)
    category5.id = UUID()
    category5.name = "Preview 1 Income"
    category5.typeValue = .income
    category5.iconName = "case"
    category5.budget = budget
    category5.amountDecimal = 1000
    
    let category6 = PlanCategoryEntity(context: dm.viewContext)
    category6.id = UUID()
    category6.name = "Preview 2 Income"
    category6.typeValue = .income
    category6.iconName = "globe"
    category6.budget = budget
    category6.amountDecimal = 1000000
    
    let vm = BudgetWizardViewModel(
        budget,
        budgetService: bundle.budgetService,
        dataService: bundle.dataService,
        notificationService: bundle.notificationService,
        analyticsService: bundle.analyticsService
    )
    
    let appState = AppState(bundle: bundle)
    appState.helpButtonVisible(true)
    
    return BudgetWizardView(vm: vm)
        .serviceBundle(bundle)
        .environmentObject(appState)
}
