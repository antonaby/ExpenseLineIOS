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
    
    @Published var name: String
    @Published var iconName: String?
    @Published var type: CategoryType
    @Published var amount: String
    @Published var isValid: Bool = false
    
    var category: PlanCategoryEntity
    var currencySymbol: String
    var delimiter: String
    var isSymbolTrailing: Bool
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ category: PlanCategoryEntity, localeId: String) {
        self.category = category
        let locale = Locale(identifier: localeId)
        self.currencySymbol = locale.currencySymbol ?? "$"
        self.delimiter = locale.decimalSeparator ?? "."
        self.isSymbolTrailing = locale.isCurrencySymbolTrailing()
        self.name = category.name ?? ""
        self.iconName = category.iconName
        self.type = category.typeValue
        
        if category.amountDecimal > 0 {
            self.amount = category.amountAsString(currencySymbol, delimiter: delimiter, trailing: isSymbolTrailing)
        } else {
            self.amount = ""
        }
        
        isFormValid.sink { [weak self] isFormValid in
            guard let self = self else { return }
            self.isValid = isFormValid
        }
        .store(in: &cancellables)
    }
    
    func getUpdatedCategory() -> PlanCategoryEntity {
        category.name = name
        category.iconName = iconName
        category.amount = amountAsDecimalNumber() as NSDecimalNumber
        category.typeValue = type
        
        return category
    }
    
    public func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
    private func amountAsDecimalNumber() -> Decimal {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = delimiter
        let cleanAmount = amount.replacingOccurrences(of: currencySymbol, with: "")
        
        return formatter.number(from: cleanAmount)?.decimalValue ?? 0
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
    
    var isIconSelected: AnyPublisher<Bool, Never> {
        $iconName.debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { iconName in
                iconName != nil
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
    
    var isFormValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(isNameValid, isIconSelected, isAmountValid)
            .map { isNameValid, isIconSelected, isAmountValid in
                isNameValid && isIconSelected && isAmountValid
            }
            .eraseToAnyPublisher()
    }
    
}

struct EditCategorySheet: View {
    
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
                Button {
                    dismiss?(vm.category)
                } label: {
                    Text("Cancel")
                        .foregroundColor(.red)
                }
                Spacer()
                Menu {
                    Button(role: .destructive) {
                        delete?(vm.category)
                    } label: {
                        Label("Delete", systemImage: "trash")
                     }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                }
                AddArrowButton {
                    update?(vm.getUpdatedCategory())
                }
                .disabled(!vm.isValid)
            }
            .padding([.top, .horizontal], 10)
            ScrollView {
                VStack(spacing: 10) {
                    HStack {
                        Button {
                            showCategrotyTemplateSheet.toggle()
                        } label: {
                            FlexibleCardView {
                                Image(systemName: vm.iconName ?? "questionmark")
                            }
                            .foregroundColor(.black)
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
                    FlexibleCardView {
                        CustomNumericField(text: vm.amount, placeholder: "Amount") {
                            CustomNumericKeybord(
                                text: $vm.amount,
                                showKeyboard: $showKeyboard,
                                currencySymbol: vm.currencySymbol,
                                delimiter: vm.delimiter,
                                isSymbolTrailing: vm.isSymbolTrailing
                            )
                        }
                        .focused($showKeyboard)
                    }
                    .frame(minHeight: 70)
                }
            }
            .padding([.top, .horizontal], 10)
            .background(Color(uiColor: .secondarySystemBackground))
        }
        .sheet(isPresented: $showCategrotyTemplateSheet) {
            CategoryTemplateSelectorView(name: $vm.name, iconName: $vm.iconName, type: $vm.type)
        }
        .interactiveDismissDisabled(true)
        .onDisappear {
            vm.cancelAll()
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
    category.iconName = "case"
    category.typeValue = .income

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
