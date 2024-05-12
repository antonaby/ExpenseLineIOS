//
//  CreateTransactionSheetView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 12.04.24.
//

import SwiftUI

struct CategorySelectorView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var category: PlanCategory?
    @Binding var categories: [PlanCategory]
    
    var body: some View {
        VStack {
            Form {
                ForEach(categories) { ctg in
                    Button {
                        category = ctg
                        dismiss()
                    } label: {
                        Text(ctg.name)
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
    
    @State var path = NavigationPath()
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                Spacer()
                ToolButton {
                    vm.createTransaction()
                    dismiss()
                }
                .disabled(!vm.isValid)
            }
            .padding([.horizontal, .top], 15)
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
                                Text(category.name)
                            } else {
                                Text("Select Category")
                            }
                        }

                    } header: {
                        Text("Base")
                    }
                    Section {
                        TextField("Amount", value: $vm.amount, format: .number.rounded(increment: 0.01))
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
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
        .onAppear {
            vm.loadCetegories()
        }
    }
}

#Preview {
    let bundle = ServiceBundle.preview
    
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
    category1.name = "Test"
    category1.budget = budget
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.name = "Other"
    category2.budget = budget
    
    let category3 = PlanCategoryEntity(context: dm.viewContext)
    category3.name = "Thrid"
    category3.budget = budget
    
    return TransactionSheetView(vm: TransactionSheetViewModel(budget: budget, budgetService: bundle.budgetService))
}
