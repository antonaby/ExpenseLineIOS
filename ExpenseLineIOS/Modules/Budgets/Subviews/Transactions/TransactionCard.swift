//
//  TransactionCard.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 31.05.24.
//

import SwiftUI

struct TransactionCard: View {
    
    var vm: BudgetViewModel
    let transaction: TransactionEntity
    
    @Binding var selectedTransaction: TransactionEntity?
    
    let onDelete: (TransactionEntity) -> Void
    
    init(vm: BudgetViewModel,
         transaction: TransactionEntity,
         selectedTransaction: Binding<TransactionEntity?>,
         onDelete: @escaping (TransactionEntity) -> Void) {
        self.vm = vm
        self.transaction = transaction
        self._selectedTransaction = selectedTransaction
        self.onDelete = onDelete
    }
    
    var body: some View {
        FlexibleCardView {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    IconView(
                        name: transaction.category?.iconNameValue ?? "question",
                        color: transaction.category?.colorValue ?? .black,
                        size: 45
                    )
                    VStack(alignment: .listRowSeparatorLeading) {
                        Text(transaction.category?.name ?? "?")
                            .font(.caption)
                        Text(transaction.name ?? "?")
                            .bold()
                    }
                    Spacer()
                    Menu {
                        Button {
                            selectedTransaction = transaction
                        } label: {
                            Text("Edit")
                        }
                        Button(role: .destructive) {
                            onDelete(transaction)
                        } label: {
                            Text("Delete")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    
                }
                Text(vm.formatAmount(transaction.amountDecimal))
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(vm.formatDate(transaction.createdAt))
                    .font(.caption)
            }
        }
    }
}

