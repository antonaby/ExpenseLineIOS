//
//  EditIncomeSourceSheet.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 07.04.24.
//

import SwiftUI

struct EditPlanCategorySheet: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding<PlanCategory> var category: PlanCategory
    @Binding<DataEditOp> var op: DataEditOp
    
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
            TextField("Amount", value: $category.amount, format: .number)
                .font(.title)
                .multilineTextAlignment(.center)
                .foregroundColor(.green)
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
    EditPlanCategorySheet(category:
            .constant(PlanCategory(
                id: UUID(), name: "My Income", amount: 1000, percent: 0, iconName: "case", createdAt: Date())),
                          op: .constant(.create))
}
