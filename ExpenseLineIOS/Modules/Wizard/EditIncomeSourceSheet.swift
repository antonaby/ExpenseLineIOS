//
//  EditIncomeSourceSheet.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 07.04.24.
//

import SwiftUI

struct EditIncomeSourceSheet: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding<IncomeSource> var incomeSource: IncomeSource
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
            TextField("Name", text: $incomeSource.name)
                .font(.title3)
            TextField("Amount", value: $incomeSource.amount, format: .number)
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
                    Label("Create", systemImage: "plus")
                        .font(.title3)
                }
                .foregroundColor(.green)
                
            }
            .padding([.bottom], 10)
        }
        .padding([.horizontal], 15)
        .interactiveDismissDisabled(op == .create)
    }
    
}

#Preview {
    EditIncomeSourceSheet(incomeSource:
            .constant(IncomeSource(
                id: UUID(), name: "My Income", amount: 1000, iconName: "case", createdAt: Date())),
                          op: .constant(.create))
}
