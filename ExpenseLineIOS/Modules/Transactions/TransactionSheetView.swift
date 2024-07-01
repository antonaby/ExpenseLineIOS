//
//  CreateTransactionSheetView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 12.04.24.
//

import SwiftUI

struct TransactionSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: TransactionSheetViewModel
    
    @FocusState private var showKeyboard: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ToolButton(icon: "x.circle", color: Color.appDestructiveLink) {
                    vm.rollback()
                    dismiss()
                }
                Spacer()
                Text("Transaction")
                    .font(.headline)
                Spacer()
                ToolButton(color: Color.appLink) {
                    vm.save()
                    dismiss()
                }
                .disabled(!vm.isValid)
            }
            .padding([.horizontal, .top], 10)
            .padding([.bottom], 5)
            .font(.title2)
            .background(Color.appBackgroundSecondary)
            NavigationStack {
                ScrollView {
                    VStack(spacing: 15) {
                        FlexibleCardView {
                            NavigationLink {
                                CategorySelectorView(category: $vm.category, categories: $vm.categories)
                            } label: {
                                HStack {
                                    IconView(
                                        name: vm.category?.iconNameValue ?? "question",
                                        color: vm.category?.colorValue ?? Color.appLink,
                                        size: 45
                                    )
                                    if let category = vm.category {
                                        Text(category.nameValue)
                                    } else {
                                        Text("Choose category")
                                    }
                                }
                                .foregroundColor(Color.appCardTextColor)
                                .font(.title2)
                            }
                        }
                        FlexibleCardView {
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Image(systemName: "wallet.pass")
                                        .frame(width: 25)
                                        .foregroundStyle(Color.appLink)
                                    TextField(text: $vm.name) {
                                        Text("Name")
                                    }
                                }
                                HStack {
                                    Image(systemName: "calendar")
                                        .frame(width: 25)
                                        .foregroundStyle(Color.appLink)
                                    DatePicker("Date", selection: $vm.date, in: ...Date())
                                }
                            }
                        }
                        FlexibleCardView {
                            CustomNumericField(text: vm.amount, placeholder: "Amount") {
                                CustomNumericKeybord(
                                    text: $vm.amount,
                                    showKeyboard: $showKeyboard,
                                    currencySymbol: vm.currencySymbol,
                                    separator: vm.separator,
                                    isSymbolTrailing: vm.isSymbolTrailing
                                )
                            }
                            .focused($showKeyboard)
                        }
                        Button {
                            vm.deleteTransaction()
                            dismiss()
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .tint(Color.appDestructiveLink)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 15)
                }
                .background(Color.appBackground)
            }
        }
        .interactiveDismissDisabled(true)
        .onAppear {
            vm.loadCetegories()
        }
        .onDisappear {
            vm.cancelAll()
        }
    }
}

#Preview("New") {
    let bundle = ServiceBundle.preview
    
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
    category1.id = UUID()
    category1.name = "Test"
    category1.budget = budget
    category1.typeValue = .income
    category1.colorValue = .blue
    category1.iconName = "018-income"
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Other"
    category2.budget = budget
    category2.typeValue = .outcomeFixed
    category2.colorValue = .cyan
    category2.iconName = "024-mortgage"
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.id = UUID()
    category3.name = "Thrid"
    category3.budget = budget
    category3.typeValue = .outcomePercent
    category3.colorValue = .green
    category3.iconName = "005-coffee"
    
    let symbol = bundle.dataService.getCurrencySymbolOrDefault("en_US")
    
    return TransactionSheetView(
        vm: TransactionSheetViewModel(transaction: nil, budget: budget, currency: symbol, budgetService: bundle.budgetService))
}

#Preview("Existing") {
    let bundle = ServiceBundle.preview
    
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
    category1.id = UUID()
    category1.name = "Test"
    category1.budget = budget
    category1.typeValue = .income
    category1.colorValue = .blue
    category1.iconName = "018-income"
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Other"
    category2.budget = budget
    category2.typeValue = .outcomeFixed
    category2.colorValue = .cyan
    category2.iconName = "024-mortgage"
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.id = UUID()
    category3.name = "Thrid"
    category3.budget = budget
    category3.typeValue = .outcomePercent
    category3.colorValue = .green
    category3.iconName = "005-coffee"
    
    let transaction = bundle.budgetService.newTransactionEntity(budget)
    transaction.name = "Preview"
    transaction.amountDecimal = 200
    transaction.createdAt = Date().addingTimeInterval(-360)
    transaction.category = category2
    
    let symbol = bundle.dataService.getCurrencySymbolOrDefault("en_US")
    
    return TransactionSheetView(
        vm: TransactionSheetViewModel(transaction: transaction, budget: budget, currency: symbol, budgetService: bundle.budgetService))
}
