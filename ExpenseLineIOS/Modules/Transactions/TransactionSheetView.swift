//
//  CreateTransactionSheetView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 12.04.24.
//

import SwiftUI

struct CategorySelectorView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var category: PlanCategoryEntity?
    @Binding var categories: [PlanCategoryEntity]
    
    var body: some View {
        List(categories) { ctg in
            Button {
                category = ctg
                dismiss()
            } label: {
                HStack {
                    Image(systemName: ctg.iconNameValue)
                        .foregroundColor(ctg.colorValue)
                        .frame(width: 25)
                    Text(ctg.nameValue)
                }
            }
            .tint(.black)
        }
        .navigationBarBackButtonHidden(true)
    }
    
}

struct TransactionSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: TransactionSheetViewModel
    
    @FocusState private var showKeyboard: Bool
    
    var body: some View {
        VStack {
            HStack {
                ToolButton(icon: "x.circle", color: .red) {
                    vm.rollback()
                    dismiss()
                }
                Spacer()
                Text("Transaction")
                    .font(.headline)
                Spacer()
                ToolButton(color: .green) {
                    vm.save()
                    dismiss()
                }
                .disabled(!vm.isValid)
            }
            .padding([.horizontal, .top], 10)
            .padding([.bottom], 5)
            .font(.title2)
            NavigationStack {
                ScrollView {
                    VStack(spacing: 15) {
                        FlexibleCardView {
                            NavigationLink {
                                CategorySelectorView(category: $vm.category, categories: $vm.categories)
                            } label: {
                                HStack {
                                    Image(systemName: vm.category?.iconNameValue ?? "questionmark")
                                        .foregroundColor(vm.category?.colorValue ?? .black)
                                    if let category = vm.category {
                                        Text(category.nameValue)
                                    } else {
                                        Text("Choose category")
                                    }
                                }
                                .foregroundColor(.black)
                                .font(.title2)
                            }
                        }
                        FlexibleCardView {
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Image(systemName: "wallet.pass")
                                        .frame(width: 25)
                                    TextField(text: $vm.name) {
                                        Text("Name")
                                    }
                                }
                                
                                HStack {
                                    Image(systemName: "calendar")
                                        .frame(width: 25)
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
                    }
                    .padding([.top, .horizontal], 10)
                }
                .background(Color(uiColor: .secondarySystemBackground))
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
    category1.iconName = "bag"
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Other"
    category2.budget = budget
    category2.typeValue = .outcomeFixed
    category2.colorValue = .cyan
    category2.iconName = "car"
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.id = UUID()
    category3.name = "Thrid"
    category3.budget = budget
    category3.typeValue = .outcomePercent
    category3.colorValue = .green
    category3.iconName = "takeoutbag.and.cup.and.straw"
    
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
    category1.iconName = "bag"
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Other"
    category2.budget = budget
    category2.typeValue = .outcomeFixed
    category2.colorValue = .cyan
    category2.iconName = "car"
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.id = UUID()
    category3.name = "Thrid"
    category3.budget = budget
    category3.typeValue = .outcomePercent
    category3.colorValue = .green
    category3.iconName = "takeoutbag.and.cup.and.straw"
    
    let transaction = bundle.budgetService.newTransactionEntity(budget)
    transaction.name = "Preview"
    transaction.amountDecimal = 200
    transaction.createdAt = Date().addingTimeInterval(-360)
    transaction.category = category2
    
    let symbol = bundle.dataService.getCurrencySymbolOrDefault("en_US")
    
    return TransactionSheetView(
        vm: TransactionSheetViewModel(transaction: transaction, budget: budget, currency: symbol, budgetService: bundle.budgetService))
}
