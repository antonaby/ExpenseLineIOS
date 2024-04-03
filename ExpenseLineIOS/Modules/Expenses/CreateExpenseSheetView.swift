//
//  CreateExpenseSheetView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 26.03.24.
//

import SwiftUI

struct CreateExpenseSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: CreateExpenseSheetViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                Spacer()
                AddArrowButton {
                    vm.createExpense()
                    dismiss()
                }
                .disabled(!vm.isValid)
            }
            // TODO: create fancy menu
            Menu {
                ForEach(vm.getSpaces()) { space in
                    Button {
                        vm.setSpace(space)
                    } label: {
                        Text(space.name ?? "Unknown")
                    }
                }
            } label: {
                if let space = vm.space {
                    Text(space.name ?? "Unknown")
                } else {
                    Text("Select Space")
                }
            }
            .menuStyle(.borderlessButton)
            TextField(text: $vm.name) {
                Text("Name")
            }
            // TODO: proper numeric text field
            TextField("Enter your score", value: $vm.amount, format: .number)
            DatePicker("Expense Date", selection: $vm.createdAt, displayedComponents: [.hourAndMinute, .date])
            Spacer()
        }
        .padding([.horizontal, .top], 15)
    }
    
}

#Preview {
    let dm = DependencyResolver.preview.databaseManager()
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    
    let plan = BudgetPlanEntity(context: dm.viewContext)
    plan.id = UUID()
    plan.planTypeValue = .mountly
    plan.budget = budget
    plan.createdAt = Date()
    plan.startsAt = Date()
    plan.endsAt = Date()
    plan.plannedExpenses = 1000
    
    dm.save()
    
    return CreateExpenseSheetView(vm: DependencyResolver.preview.createExpenseSheetViewModel(plan))
}
