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
    @Published var amount: String
    
    var category: PlanCategoryEntity
    
    init(_ category: PlanCategoryEntity) {
        self.category = category
        
        self.name = category.name ?? ""
        self.amount = "" //category.amount
    }
    
    func getUpdatedCategory() -> PlanCategoryEntity {
        category.name = name
        category.amount = 0
        
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
                Group {
                    TextField("Name", text: $vm.name)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .background(RoundedRectangle(cornerRadius: 10).fill(.white))
                .padding([.top], 10)
                .padding([.horizontal], 10)
                 Group {
                    TextField("Amount", text: $vm.amount)
                        .inputView(hint: "Amount") {
                            CustomNumericKeybord(showKeyboard: $showKeyboard, text: $vm.amount)
                        }
                        .focused($showKeyboard)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.green)
                        .padding()
                }
                .background(RoundedRectangle(cornerRadius: 10).fill(.white))
                .padding([.horizontal], 10)
                Spacer()
            }
            .background(Color(uiColor: .secondarySystemBackground))
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

    return EditCategorySheet(title: "Save", vm: EditPlanCategorySheetViewModel(category))
}
