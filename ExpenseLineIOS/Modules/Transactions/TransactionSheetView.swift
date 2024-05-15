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
        VStack {
            Form {
                ForEach(categories) { ctg in
                    Button {
                        category = ctg
                        dismiss()
                    } label: {
                        Text(ctg.nameValue)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
}

struct TransactionSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: TransactionSheetViewModel
    
    @FocusState private var showKeyboard: Bool
    @State var path = NavigationPath()
    
    var body: some View {
        VStack {
            HStack {
                ToolButton(icon: "x.circle", color: .red) {
                    vm.rollback()
                    dismiss()
                }
                Spacer()
                ToolButton(color: .green) {
                    vm.save()
                    dismiss()
                }
                .disabled(!vm.isValid)
            }
            .padding([.horizontal, .top], 15)
            .padding([.bottom], 5)
            .font(.title2)
            NavigationStack(path: $path) {
                Form {
                    Section {
                        TextField(text: $vm.name) {
                            Text("Name")
                        }
                        NavigationLink {
                            CategorySelectorView(category: $vm.category, categories: $vm.categories)
                        } label: {
                            if let category = vm.category {
                                Text(category.nameValue)
                            } else {
                                Text("Select Category")
                            }
                        }
                    } header: {
                        Text("Base")
                    }
                    Section {
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
                    } header: {
                        Text("Amount")
                    }
                    Section {
                        DatePicker("Date", selection: $vm.date, in: ...Date())
                    } header: {
                        Text("Other")
                    }
                }
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
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Other"
    category2.budget = budget
    category2.typeValue = .outcomeFixed
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.id = UUID()
    category3.name = "Thrid"
    category3.budget = budget
    category3.typeValue = .outcomePercent
    
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
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Other"
    category2.budget = budget
    category2.typeValue = .outcomeFixed
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.id = UUID()
    category3.name = "Thrid"
    category3.budget = budget
    category3.typeValue = .outcomePercent
    
    let transaction = bundle.budgetService.newTransactionEntity(budget)
    transaction.name = "Preview"
    transaction.amountDecimal = 200
    transaction.createdAt = Date().addingTimeInterval(-360)
    transaction.category = category2
    
    let symbol = bundle.dataService.getCurrencySymbolOrDefault("en_US")
    
    return TransactionSheetView(
        vm: TransactionSheetViewModel(transaction: transaction, budget: budget, currency: symbol, budgetService: bundle.budgetService))
}
