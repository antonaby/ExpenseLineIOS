//
//  EditDailyPlanCategorySheet.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 09.04.24.
//

import SwiftUI

struct EditDailyPlanCategorySheet: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var category: PlanCategory
    @Binding var op: CategoryActionOperation
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    op = .none
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                }
                .foregroundColor(.red)
            }
            .padding([.top], 10)
            .padding([.bottom], 5)
            TextField("Name", text: $category.name)
                .font(.title3)
            TextField("Amount", value: $category.percent, format: .percent)
                .font(.title)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
                .keyboardType(.decimalPad)
            Spacer()
            HStack {
                Button {
                    op = .delete
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                }
                .foregroundColor(.red)
                Button {
                    dismiss()
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
    EditDailyPlanCategorySheet(category:
            .constant(PlanCategory(
                id: UUID(), name: "Groceries", amount: 0, percent: 0.2, iconName: "cart", type: .outcomeFixed, createdAt: Date())),
                          op: .constant(.create))
}
