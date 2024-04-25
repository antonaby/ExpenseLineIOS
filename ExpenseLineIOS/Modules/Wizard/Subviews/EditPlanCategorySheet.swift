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
    @Published var amount: Double
    
    var category: PlanCategoryEntity
    
    init(_ category: PlanCategoryEntity) {
        self.category = category
        
        self.name = category.name ?? ""
        self.amount = category.amount
    }
    
    func getUpdatedCategory() -> PlanCategoryEntity {
        category.name = name
        category.amount = amount
        
        return category
    }
    
}

struct EditPlanCategorySheet: View {
    
    @Environment(\.updateCategory) private var update
    @Environment(\.deleteCategory) private var delete
    @Environment(\.dismissCategory) private var dismiss
    
    var title: String
    @StateObject var vm: EditPlanCategorySheetViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    delete?(vm.category)
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                }
                .foregroundColor(.red)
                Spacer()
                Button {
                    dismiss?(vm.category)
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                }
                .foregroundColor(.red)
            }
            .padding([.top], 10)
            .padding([.bottom], 5)
            TextField("Name", text: $vm.name)
                .font(.title2)
                .multilineTextAlignment(.center)
            TextField("Amount", value: $vm.amount, format: .number)
                .font(.title)
                .multilineTextAlignment(.center)
                .foregroundColor(.green)
                .keyboardType(.decimalPad)
            Spacer()
            HStack {
                
                Button {
                    update?(vm.getUpdatedCategory())
                } label: {
                    Label(title, systemImage: "plus")
                        .font(.title3)
                }
                .foregroundColor(.green)
                
            }
            .padding([.bottom], 10)
        }
        .padding([.horizontal], 15)
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

    return EditPlanCategorySheet(title: "Preview", vm: EditPlanCategorySheetViewModel(category))
}
