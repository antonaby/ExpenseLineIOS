//
//  EditIncomeSourceSheet.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 07.04.24.
//

import SwiftUI

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
    @Published var iconName: String
    @Published var amount: String
    
    var category: PlanCategoryEntity
    var currencySymbol: String
    var delimiter: String
    var isSymbolTrailing: Bool
    
    init(_ category: PlanCategoryEntity, localeId: String) {
        self.category = category
        let locale = Locale(identifier: localeId)
        self.currencySymbol = locale.currencySymbol ?? "$"
        self.delimiter = locale.decimalSeparator ?? "."
        self.isSymbolTrailing = locale.isCurrencySymbolTrailing()
        self.name = category.name ?? ""
        self.iconName = category.iconName ?? "questionmark.app"
        
        if category.amountDecimal > 0 {
            self.amount = category.amountAsString(currencySymbol, delimiter: delimiter, trailing: isSymbolTrailing)
        } else {
            self.amount = ""
        }
    }
    
    func getUpdatedCategory() -> PlanCategoryEntity {
        category.name = name
        category.iconName = iconName
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = delimiter
        let cleanAmount = amount.replacingOccurrences(of: currencySymbol, with: "")
        
        let number = formatter.number(from: cleanAmount)?.decimalValue ?? 0
        category.amount = number as NSDecimalNumber
        
        return category
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
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
                .padding([.trailing], 5)
                Button {
                    update?(vm.getUpdatedCategory())
                } label: {
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .foregroundColor(.green)
                }
            }
            .padding([.top, .horizontal], 10)
            VStack {
                Button {
                    showCategrotyTemplateSheet.toggle()
                } label: {
                    HStack {
                        BaseCardView {
                            Image(systemName: vm.iconName)
                        }
                        BaseCardView {
                            HStack {
                                Text(vm.name)
                                Spacer()
                            }
                        }
                    }
                    .foregroundColor(.black)
                    .font(.title3)
                    .padding([.top], 10)
                    .padding([.horizontal], 10)
                }
                BaseCardView {
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
                .padding([.horizontal], 10)
                .frame(maxHeight: 80)
                Spacer()
            }
            .background(Color(uiColor: .secondarySystemBackground))
        }
        .sheet(isPresented: $showCategrotyTemplateSheet) {
            CategoryTemplateSelectorView(name: $vm.name, iconName: $vm.iconName)
        }
        .interactiveDismissDisabled(true)
    }
    
}

#Preview {
    let busgetService = DependencyResolver.preview.budgetService()
    let budget = busgetService.newBudgetEntity()
    budget.name = "Preview"
    
    let category = busgetService.newCategoryEntity(budget)
    category.name = "Preview"
    category.amount = 1000
    category.iconName = "case"
    category.typeValue = .income

    return EditCategorySheet(title: "Save", vm: EditPlanCategorySheetViewModel(category, localeId: "de_DE"))
        .environmentObject(DependencyResolver.preview)
}
