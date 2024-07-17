//
//  TransactionView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 07.06.24.
//

import SwiftUI

struct TransactionView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var formatters: FormattersHolder
    @EnvironmentObject var analyticsService: AnalyticsService
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var budgetService: BudgetService
    
    @StateObject var vm: TransactionViewModel
    @State var editSheetOpen: Bool = false
    
    var body: some View {
        ScrollView {
            ContentSizeCardView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        IconView(
                            name: vm.transaction.category?.iconNameValue ?? "question",
                            size: 45)
                        .accessibilityLabel(vm.transaction.category?.nameValue ?? "Category")
                        VStack(alignment: .listRowSeparatorLeading) {
                            Text(vm.transaction.category?.nameValue ?? "Category")
                                .font(.caption)
                                .foregroundStyle(Color.appLinkInactive)
                            Text(vm.transaction.nameValue)
                                .bold()
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text(formatters.formatAmount(vm.transaction.amountDecimal))
                        .font(.largeTitle)
                    Text(formatters.formatDate(vm.transaction.createdAt))
                        .font(.caption)
                        .foregroundStyle(Color.appLinkInactive)
                }
            }
            FlexibleCardView {
                HStack {
                    Button {
                        editSheetOpen.toggle()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                    }
                    .tint(Color.appLink)
                    Divider()
                    Button {
                        vm.deleteTransaction()
                        dismiss()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .tint(Color.appDestructiveLink)
                }
            }
        }
        .padding(.horizontal, 20)
        .background(Color.appBackground)
        .sheet(isPresented: $editSheetOpen, onDismiss: onEditSheetClosed) {
            TransactionSheetView(
                vm: TransactionSheetViewModel(transaction: vm.transaction,
                                              budget: vm.budget,
                                              currency: vm.currency,
                                              budgetService: budgetService,
                                              analyticsService: analyticsService))
                .presentationDetents([.medium])
                .preferredColorScheme(appState.colorScheme)
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
        transaction: transaction, budget: budget, currency: currency, 
        budgetService: budgetService,
        analyticsService: bundle.analyticsService
    )
    
    try! budgetService.save()
    
    return TransactionView(vm: vm)
        .serviceBundle(bundle)
        .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
        .environmentObject(AppState(bundle: bundle))
}
