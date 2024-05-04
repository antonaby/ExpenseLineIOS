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
    @Published var color: Color
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
    
    init(_ category: PlanCategoryEntity, localeId: String) {
        self.category = category
        let locale = Locale(identifier: localeId)
        self.locale = locale
        self.name = category.name ?? ""
        self.color = category.colorValue
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
        
        if category.percentDecimal > 0 {
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
        category.iconName = template?.iconName ?? "questionmark"
        if type == .outcomePercent {
            category.percent = convertToDecimalNumber(percent, symbol: EditPlanCategorySheetViewModel.dafaultPercentSymbol)
            category.amountDecimal = 0
        } else {
            category.amount = convertToDecimalNumber(amount, symbol: currencySymbol)
            category.percentDecimal = 0
        }
        category.typeValue = type
        category.colorValue = color
        category.templateId = template?.id
        
        return category
    }
    
    public func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
    private func convertToDecimalNumber(_ value: String, symbol: String) -> NSDecimalNumber {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = separator
        let cleanAmount = value.replacingOccurrences(of: symbol, with: "")
        let result = formatter.number(from: cleanAmount)?.decimalValue ?? 0
        
        return result as NSDecimalNumber
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
    
    @EnvironmentObject var resolver: DependencyResolver
    
    @Environment(\.updateCategory) private var update
    @Environment(\.deleteCategory) private var delete
    @Environment(\.dismissCategory) private var dismiss
    
    var title: String
    @StateObject var vm: EditPlanCategorySheetViewModel
    
    @FocusState private var showKeyboard: Bool
    
    @State var placeholder: String = "Amount"
    @State var showCategrotyTemplateSheet: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                ToolButton(icon: "x.circle", color: .red) {
                    dismiss?(vm.category)
                }
                Spacer()
                ToolButton(color: .green) {
                    update?(vm.getUpdatedCategory())
                }
                .disabled(!vm.isValid)
            }
            .padding([.top, .horizontal], 10)
            .padding([.bottom], 5)
            .font(.title2)
            ScrollView {
                VStack(spacing: 15) {
                    PromptView {
                        Text("Chose **icon**, fill **name** and **amount**")
                            .padding([.top], 10)
                    }
                    HStack(spacing: 15) {
                        Button {
                            showCategrotyTemplateSheet.toggle()
                        } label: {
                            FlexibleCardView {
                                Image(systemName: vm.template?.iconName ?? "questionmark")
                            }
                            .foregroundColor(vm.color)
                            .frame(maxWidth: 50)
                        }
                        FlexibleCardView {
                            HStack {
                                TextField("Name", text: $vm.name)
                            }
                        }
                    }
                    .font(.title3)
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
                        }
                    }
                    .frame(minHeight: 70)
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
                                            .foregroundColor(categoryType == vm.type ? .green : .black)
                                    }
                                }
                            }
                        }
                    }
                    .frame(minHeight: 50)
                    Menu {
                        Button(role: .destructive) {
                            delete?(vm.category)
                        } label: {
                            Label("Delete", systemImage: "trash")
                         }
                    } label: {
                        Text("More actions")
                    }
                }
            }
            .padding([.top, .horizontal], 10)
            .background(Color(uiColor: .secondarySystemBackground))
        }
        .sheet(isPresented: $showCategrotyTemplateSheet, onDismiss: onIconSelected) {
            CategoryTemplateSelectorView(color: $vm.color, selectedTemplate: $vm.template, type: vm.type)
        }
        .interactiveDismissDisabled(true)
        .onAppear {
            let dataService = resolver.dataService()
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
            CategoryLebelView("Mountly", lebel: "house")
        case .outcomePercent:
            CategoryLebelView("Daily", lebel: "takeoutbag.and.cup.and.straw")
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
    let busgetService = DependencyResolver.preview.budgetService()
    let budget = busgetService.newBudgetEntity()
    
    let category = busgetService.newCategoryEntity(budget)
    category.name = "Preview"
    category.amount = 1000
    category.colorValue = .orange
    category.iconName = "case"
    category.typeValue = .income
    category.templateId = UUID(uuidString: "4e794d37-e5fb-4574-b105-4ec0a2d46ce9")!

    return EditCategorySheet(title: "Save", vm: EditPlanCategorySheetViewModel(category, localeId: "de_DE"))
        .environmentObject(DependencyResolver.preview)
}

#Preview("New") {
    let busgetService = DependencyResolver.preview.budgetService()
    let budget = busgetService.newBudgetEntity()
    
    let category = busgetService.newCategoryEntity(budget)
    category.typeValue = .income

    return EditCategorySheet(title: "Save", vm: EditPlanCategorySheetViewModel(category, localeId: "de_DE"))
        .environmentObject(DependencyResolver.preview)
}
