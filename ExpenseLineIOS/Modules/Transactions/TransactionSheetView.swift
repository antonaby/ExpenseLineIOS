//
//  CreateTransactionSheetView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 12.04.24.
//

import SwiftUI

struct TransactionSheetView: View {
    
    @EnvironmentObject var analyticsService: AnalyticsService
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
                .accessibilityLabel("Close")
                .accessibilityElement(children: .combine)
                Spacer()
                Text("Expense Record")
                    .font(.headline)
                Spacer()
                ToolButton(color: Color.appLink) {
                    if vm.transaction.isNew {
                        analyticsService.logEvent(name: AnalyticsService.TRANSACTION_CREATED)
                    } else {
                        analyticsService.logEvent(name: AnalyticsService.TRANSACTION_EDITED)
                    }
                    vm.save()
                    dismiss()
                }
                .disabled(!vm.isValid)
                .accessibilityLabel("Save")
                .accessibilityElement(children: .combine)
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
                                if let category = vm.category {
                                    HStack {
                                        IconView(
                                            name: vm.category?.iconNameValue ?? "question",
                                            size: 45
                                        )
                                        .accessibilityLabel(category.nameValue)
                                        Text(category.nameValue)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                } else {
                                    HStack {
                                        Text("Choose Category")
                                            .frame(height: 45)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            .font(.title2)
                            .foregroundColor(Color.appCardTextColor)
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
                            CustomNumericField(text: vm.amount, placeholder: String(localized: "Amount")) {
                                CustomNumericKeybord(
                                    text: $vm.amount,
                                    showKeyboard: $showKeyboard,
                                    currencySymbol: vm.currencySymbol,
                                    separator: vm.separator,
                                    isSymbolTrailing: vm.isSymbolTrailing
                                )
                            }
                            .focused($showKeyboard)
                            .accessibilityLabel("Amount")
                            .accessibilityElement(children: .combine)
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
    category1.iconName = "018-income"
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Other"
    category2.budget = budget
    category2.typeValue = .outcomeFixed
    category2.iconName = "024-mortgage"
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.id = UUID()
    category3.name = "Thrid"
    category3.budget = budget
    category3.typeValue = .outcomePercent
    category3.iconName = "005-coffee"
    
    let symbol = bundle.dataService.getCurrencySymbolOrDefault("en_US")
    
    return TransactionSheetView(
        vm: TransactionSheetViewModel(transaction: nil, budget: budget, currency: symbol,
                                      budgetService: bundle.budgetService,
                                      analyticsService: bundle.analyticsService))
    .serviceBundle(bundle)
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
    category1.iconName = "018-income"
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Other"
    category2.budget = budget
    category2.typeValue = .outcomeFixed
    category2.iconName = "024-mortgage"
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.id = UUID()
    category3.name = "Thrid"
    category3.budget = budget
    category3.typeValue = .outcomePercent
    category3.iconName = "005-coffee"
    
    let transaction = bundle.budgetService.newTransactionEntity(budget)
    transaction.name = "Preview"
    transaction.amountDecimal = 200
    transaction.createdAt = Date().addingTimeInterval(-360)
    transaction.category = category2
    
    let symbol = bundle.dataService.getCurrencySymbolOrDefault("en_US")
    
    return TransactionSheetView(
        vm: TransactionSheetViewModel(transaction: transaction, budget: budget, currency: symbol, 
                                      budgetService: bundle.budgetService,
                                      analyticsService: bundle.analyticsService))
    .serviceBundle(bundle)
}
