//
//  EditIncomeSourceSheet.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 07.04.24.
//

import SwiftUI
import Combine

struct CategoryAction {
    
    typealias Action = (PlanCategoryEntity) -> Void
    let action: Action
    
    func callAsFunction(_ category: PlanCategoryEntity) {
        action(category)
    }
    
}

struct UpdateCategoryActionKey: EnvironmentKey {
    
    static var defaultValue: CategoryAction?
    
}

struct DeleteCategoryActionKey: EnvironmentKey {
    
    static var defaultValue: CategoryAction?
    
}

struct DismissCategoryActionKey: EnvironmentKey {
    
    static var defaultValue: CategoryAction?
    
}

extension EnvironmentValues {
    
    var updateCategory: CategoryAction? {
       get { self[UpdateCategoryActionKey.self] }
       set { self[UpdateCategoryActionKey.self] = newValue }
    }
    
    var deleteCategory: CategoryAction? {
        get { self[DeleteCategoryActionKey.self] }
        set { self[DeleteCategoryActionKey.self] = newValue }
    }
    
    var dismissCategory: CategoryAction? {
        get { self[DismissCategoryActionKey.self] }
        set { self[DismissCategoryActionKey.self] = newValue }
    }
    
}

extension View {
    
    func onUpdateCategory(_ action: @escaping CategoryAction.Action) -> some View {
        self.environment(\.updateCategory, CategoryAction(action: action))
    }
    
    func onDeleteCategory(_ action: @escaping CategoryAction.Action) -> some View {
        self.environment(\.deleteCategory, CategoryAction(action: action))
    }
    
    func onDismissCategory(_ action: @escaping CategoryAction.Action) -> some View {
        self.environment(\.dismissCategory, CategoryAction(action: action))
    }
    
}

class EditPlanCategorySheetViewModel: ObservableObject {
    
    static let defaultSymbol = "$"
    static let defaultSeparator = "."
    static let dafaultPercentSymbol = "%"
    
    @Published var name: String
    @Published var template: CategoryTemplate?
    @Published var type: CategoryType
    @Published var amount: String
    @Published var percent: String
    @Published var isValid: Bool = false
    
    var category: PlanCategoryEntity
    var locale: Locale
    
    private var cancellables = Set<AnyCancellable>()
    
    var currencySymbol: String {
        return locale.currencySymbolOrDefault(EditPlanCategorySheetViewModel.defaultSymbol)
    }
    
    var separator: String {
        locale.decimalSepapatorOrDefault(EditPlanCategorySheetViewModel.defaultSeparator)
    }
    
    var isSymbolTrailing: Bool {
        locale.isCurrencySymbolTrailing()
    }
    
    init(_ category: PlanCategoryEntity, currencySymbol: CurrencySymbol) {
        self.category = category
        let locale = currencySymbol.locale
        self.locale = locale
        self.name = category.name ?? ""
        self.type = category.typeValue
        
        if category.amountDecimal > 0 {
            self.amount = category.amountAsString(
                symbol: locale.currencySymbolOrDefault(EditPlanCategorySheetViewModel.defaultSymbol),
                delimiter: locale.decimalSepapatorOrDefault(EditPlanCategorySheetViewModel.defaultSeparator),
                trailing: locale.isCurrencySymbolTrailing()
            )
        } else {
            self.amount = ""
        }
        
        if category.percentDecimalFraction > 0 {
            self.percent = category.percentAsString(
                delimiter: locale.decimalSepapatorOrDefault(EditPlanCategorySheetViewModel.defaultSeparator),
                symbol: EditPlanCategorySheetViewModel.dafaultPercentSymbol
            )
        } else {
            self.percent = ""
        }
        
        isFormValid.sink { [weak self] isFormValid in
            guard let self = self else { return }
            self.isValid = isFormValid
        }
        .store(in: &cancellables)
    }
    
    func getUpdatedCategory() -> PlanCategoryEntity {
        category.name = name
        category.iconName = template?.iconName ?? "question"
        if type == .outcomePercent {
            category.percentDecimalFraction = convertToDecimalNumber(percent, symbol: EditPlanCategorySheetViewModel.dafaultPercentSymbol)
            category.amountDecimal = 0
        } else {
            category.amountDecimal = convertToDecimalNumber(amount, symbol: currencySymbol)
            category.percentDecimalFraction = 0
        }
        category.typeValue = type
        category.templateId = template?.id
        category.isNew = false
        
        return category
    }
    
    public func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
    private func convertToDecimalNumber(_ value: String, symbol: String) -> Decimal {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = separator
        let cleanAmount = value.replacingOccurrences(of: symbol, with: "")
        let result = formatter.number(from: cleanAmount)?.decimalValue ?? 0
        
        return result
    }
    
}

extension EditPlanCategorySheetViewModel {
    
    var isNameValid: AnyPublisher<Bool, Never> {
        $name.debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { name in
                !name.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    var isTemplateSelected: AnyPublisher<Bool, Never> {
        $template.debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { template in
                template != nil
            }
            .eraseToAnyPublisher()
    }

    var isAmountValid: AnyPublisher<Bool, Never> {
        $amount.debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { amount in
                !amount.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    var isPercentValid: AnyPublisher<Bool, Never> {
        $percent.debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { percent in
                !percent.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    var isAmountOrPercentValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isAmountValid, isPercentValid)
            .map { [weak self] isAmountValid, isPercentValid in
                guard let self = self else {
                    return isAmountValid || isPercentValid
                }
                
                if self.type == .outcomePercent {
                    return isPercentValid
                }
                
                return isAmountValid
            }
            .eraseToAnyPublisher()
    }
    
    var isFormValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(isNameValid, isTemplateSelected, isAmountOrPercentValid)
            .map { isNameValid, isTemplateSelected, isAmountOrPercentValid in
                isNameValid && isTemplateSelected && isAmountOrPercentValid
            }
            .eraseToAnyPublisher()
    }
    
}

struct EditCategorySheet: View {
    
    @EnvironmentObject var analyticsService: AnalyticsService
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    
    @Environment(\.updateCategory) private var update
    @Environment(\.deleteCategory) private var delete
    @Environment(\.dismissCategory) private var dismiss
    
    var title: String
    @StateObject var vm: EditPlanCategorySheetViewModel
    
    @FocusState private var showKeyboard: Bool
    
    @State var placeholder: String = "Amount"
    @State var showCategrotyTemplateSheet: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ToolButton(icon: "x.circle", color: Color.appDestructiveLink) {
                    dismiss?(vm.category)
                }
                .accessibilityLabel("Close")
                .accessibilityElement(children: .combine)
                Spacer()
                Text("Category")
                    .font(.headline)
                Spacer()
                ToolButton(color: Color.appLink) {
                    if vm.category.isNew {
                        analyticsService.logEvent(name: AnalyticsService.CATEGORY_CREATED)
                    } else {
                        analyticsService.logEvent(name: AnalyticsService.CATEGORY_EDITED)
                    }
                    update?(vm.getUpdatedCategory())
                }
                .disabled(!vm.isValid)
                .accessibilityLabel("Save")
                .accessibilityElement(children: .combine)
            }
            .padding([.top, .horizontal], 10)
            .padding([.bottom], 5)
            .font(.title2)
            .background(Color.appBackgroundSecondary)
            ScrollView {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        FlexibleCardView {
                            Button {
                                showCategrotyTemplateSheet.toggle()
                            } label: {
                                IconView(
                                    name: vm.template?.iconName ?? "question",
                                    size: 45
                                )
                                .accessibilityLabel(vm.name)
                            }
                        }
                        .frame(width: 75)
                        FlexibleCardView {
                            HStack {
                                TextField("Name", text: $vm.name)
                                    .font(.title3)
                            }
                        }
                    }
                    .font(.title3)
                    .frame(minHeight: 50)
                    FlexibleCardView {
                        VStack(spacing: 10) {
                            Text("Catgeory type")
                                .font(.caption)
                            HStack {
                                ForEach(CategoryType.allCases) { categoryType in
                                    Button {
                                        vm.type = categoryType
                                    } label: {
                                        CategoryLabel(categoryType)
                                            .frame(maxWidth: .infinity)
                                            .foregroundColor(categoryType == vm.type ? Color.appLink : Color.appCardTextColor)
                                    }
                                }
                            }
                        }
                    }
                    .frame(minHeight: 50)
                    FlexibleCardView {
                        if vm.type == .outcomePercent {
                            CustomNumericField(text: vm.percent, placeholder: "Percent") {
                                CustomNumericKeybord(
                                    text: $vm.percent,
                                    showKeyboard: $showKeyboard,
                                    currencySymbol: EditPlanCategorySheetViewModel.dafaultPercentSymbol,
                                    separator: vm.separator,
                                    isSymbolTrailing: true
                                )
                            }
                            .focused($showKeyboard)
                            .accessibilityLabel("Percent")
                            .accessibilityElement(children: .combine)
                        } else {
                            CustomNumericField(text: vm.amount, placeholder: "Amount") {
                                CustomNumericKeybord(
                                    text: $vm.amount,
                                    showKeyboard: $showKeyboard,
                                    currencySymbol: vm.currencySymbol,
                                    separator: vm.separator,
                                    isSymbolTrailing: vm.isSymbolTrailing
                                )
                            }
                            .focused($showKeyboard)
                            .accessibilityLabel("Amount")
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .frame(minHeight: 70)
                    Button {
                        delete?(vm.category)
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .tint(Color.appDestructiveLink)
                    }
                }
            }
            .padding([.top, .horizontal], 10)
            .background(Color.appBackground)
        }
        .sheet(isPresented: $showCategrotyTemplateSheet, onDismiss: onIconSelected) {
            CategoryTemplateSelectorView(selectedTemplate: $vm.template, type: vm.type)
                .preferredColorScheme(appState.colorScheme)
        }
        .interactiveDismissDisabled(true)
        .onAppear {
            if let templateId = vm.category.templateId {
                vm.template = dataService.getTemplateById(templateId)
            }
        }
        .onDisappear {
            vm.cancelAll()
        }
    }
    
    func onIconSelected() {
        if let template = vm.template {
            vm.name = template.name
        }
    }
    
    @ViewBuilder
    func CategoryLabel(_ type: CategoryType) -> some View {
        switch type {
        case .income:
            CategoryLebelView("Income", lebel: "case")
        case .outcomeFixed:
            CategoryLebelView("Fixed", lebel: "house")
        case .outcomePercent:
            CategoryLebelView("Flexible", lebel: "takeoutbag.and.cup.and.straw")
        }
    }
    
    @ViewBuilder
    func CategoryLebelView(_ name: String, lebel: String) -> some View {
        VStack {
            Image(systemName: lebel)
                .font(.title2)
            Text(name)
                .font(.caption)
        }
    }
    
}

#Preview("Existing") {
    let bundle = ServiceBundle.preview
    let template = bundle.dataService.getTemplateById("ctg.income.salary")
    let budget = bundle.budgetService.newBudgetEntity()
    let category = bundle.budgetService.newCategoryEntity(budget)
    category.name = "Preview"
    category.amount = 1000
    category.typeValue = .income
    category.templateId = template?.id

    return EditCategorySheet(title: "Save", 
                             vm: EditPlanCategorySheetViewModel(category,
                                                                currencySymbol: CurrencySymbol(id: "de_DE", name: "Preview")))
    .serviceBundle(bundle)
    .environmentObject(AppState(bundle: bundle))
}

#Preview("New") {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    let category = bundle.budgetService.newCategoryEntity(budget)
    category.typeValue = .income

    return EditCategorySheet(title: "Save", 
                             vm: EditPlanCategorySheetViewModel(category,
                                                                currencySymbol: CurrencySymbol(id: "de_DE", name: "Preview")))
    .serviceBundle(bundle)
    .environmentObject(AppState(bundle: bundle))
}
