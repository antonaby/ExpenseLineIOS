//
//  TransactionView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 07.06.24.
//

import SwiftUI

struct TransactionView: View {
    
    @EnvironmentObject var formatters: FormattersHolder
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var budgetService: BudgetService
    
    @StateObject var vm: TransactionViewModel
    @State var editSheetOpen: Bool = false
    
    var body: some View {
        VStack {
            ContentSizeCardView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        IconView(
                            name: vm.transaction.category?.iconNameValue ?? "question",
                            color: vm.transaction.category?.colorValue ?? .black,
                            size: 45)
                        VStack(alignment: .listRowSeparatorLeading) {
                            Text(vm.transaction.category?.nameValue ?? "Category")
                                .font(.caption)
                            Text(vm.transaction.nameValue)
                                .bold()
                        }
                        Spacer()
                        Button {
                            editSheetOpen.toggle()
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(Color("FrDefault"))
                                .frame(width: 50, height: 50, alignment: .topTrailing)
                                .padding([.top, .trailing], 10)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text(formatters.formatAmount(vm.transaction.amountDecimal))
                        .font(.largeTitle)
                    Text(formatters.formatDate(vm.transaction.createdAt))
                        .font(.caption)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color("BgDefault"))
        .sheet(isPresented: $editSheetOpen, onDismiss: onEditSheetClosed) {
            TransactionSheetView(
                vm: TransactionSheetViewModel(transaction: vm.transaction,
                                              budget: vm.budget,
                                              currency: vm.currency,
                                              budgetService: budgetService))
                .presentationDetents([.medium])
        }
    }
    
    func onEditSheetClosed() {
        vm.reloadTransaction()
    }
    
}

#Preview {
    let bundle = ServiceBundle.preview
    let budgetService = bundle.budgetService
    let budget = budgetService.newBudgetEntity()
    
    let category = budgetService.newCategoryEntity(budget)
    category.name = "Preview"
    category.typeValue = .outcomePercent
    category.iconName = "fi-gym"
    category.colorValue = .purple
    category.percentDecimal = 0.2
    
    let transaction = budgetService.newTransactionEntity(budget)
    transaction.name = "Preview"
    transaction.amountDecimal = 3000
    transaction.createdAt = Date()
    transaction.category = category
    transaction.budget = budget
    transaction.day = Date()
    
    let currency = bundle.dataService.getCurrencySymbolOrDefault("en_US")
    
    let vm = TransactionViewModel(
        transaction: transaction, budget: budget, currency: currency, budgetService: budgetService
    )
    
    try! budgetService.save()
    
    return TransactionView(vm: vm)
        .serviceBundle(bundle)
        .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
}
