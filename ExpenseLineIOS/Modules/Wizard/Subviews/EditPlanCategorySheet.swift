//
//  EditIncomeSourceSheet.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 07.04.24.
//

import SwiftUI

enum CategoryActionOperation {
    case none
    case create
    case update
    case delete
}

struct CategoryAction {
    
    typealias Action = (PlanCategory) -> Void
    let action: Action
    
    func callAsFunction(_ category: PlanCategory) {
        action(category)
    }
    
}

struct UpdateCategoryActionKey: EnvironmentKey {
    
    static var defaultValue: CategoryAction?
    
}

struct DeleteCategoryActionKey: EnvironmentKey {
    
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
    
}

extension View {
    
    func onUpdateCategory(_ action: @escaping CategoryAction.Action) -> some View {
        self.environment(\.updateCategory, CategoryAction(action: action))
    }
    
    func onDeleteCategory(_ action: @escaping CategoryAction.Action) -> some View {
        self.environment(\.deleteCategory, CategoryAction(action: action))
    }
    
}

class EditPlanCategorySheetViewModel: ObservableObject {
    
    @Published var category: PlanCategory
    
    init(_ category: PlanCategory) {
        self.category = category
    }
    
    func getUpdatedCategory() -> PlanCategory {
        category //TODO: return updated
    }
    
}

struct EditPlanCategorySheet: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.updateCategory) private var update
    @Environment(\.deleteCategory) private var delete
    
    @StateObject var vm: EditPlanCategorySheetViewModel
    var op: CategoryActionOperation
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                }
                .foregroundColor(.red)
            }
            .padding([.top], 10)
            .padding([.bottom], 5)
            TextField("Name", text: $vm.category.name)
                .font(.title3)
            TextField("Amount", value: $vm.category.amount, format: .number)
                .font(.title)
                .multilineTextAlignment(.center)
                .foregroundColor(.green)
                .keyboardType(.decimalPad)
            Spacer()
            HStack {
                Button {
                    delete?(vm.category)
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                }
                .foregroundColor(.red)
                Button {
                    update?(vm.getUpdatedCategory())
                } label: {
                    Label(labelName(), systemImage: "plus")
                        .font(.title3)
                }
                .foregroundColor(.green)
                
            }
            .padding([.bottom], 10)
        }
        .padding([.horizontal], 15)
        .interactiveDismissDisabled(op == .create)
    }
    
    func labelName() -> String {
        return op == .create ? "Create" : "Update"
    }
    
}

#Preview {
    let category = PlanCategory(
        id: UUID(),
        name: "My Income",
        amount: 1000,
        percent: 0,
        iconName: "case",
        type: .income,
        createdAt: Date()
    )
    
    return EditPlanCategorySheet(vm: EditPlanCategorySheetViewModel(category), op: .create)
}
