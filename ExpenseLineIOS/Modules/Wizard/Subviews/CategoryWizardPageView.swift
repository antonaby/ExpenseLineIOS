//
//  CategoryWizardPageView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 23.04.24.
//

import SwiftUI

enum CategoryEditOperation {
    
    case none
    case create
    case edit
    case delete
    
}

class CategoryWizardPageViewModel: ObservableObject {
    
    @Published var categories: [PlanCategory]
    
    private var budget: BudgetEntity
    
    init(_ budget: BudgetEntity) {
        self.budget = budget
        self.categories = []
    }
 
    func selectCategory(_ category: PlanCategory, op: CategoryEditOperation) {
        
    }
    
}

struct CategoryWizardPageView: View {
    
    @ObservedObject var vm: CategoryWizardPageViewModel
    
    var body: some View {
        VStack {
            Form {
                Section {
                    ForEach(vm.categories) { category in
                        Button {
                            vm.selectCategory(category, op: .edit)
                            //sheet = .incomeSource
                        } label: {
                            HStack {
                                Image(systemName: category.iconName)
                                Text(category.name)
                                Spacer()
                                Text(category.amount, format: .number.rounded(increment: 0.01))
                                //Text(vm.currency)
                            }
                            .foregroundColor(.black)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                vm.selectCategory(category, op: .delete)
                                //vm.performEditOps()
                            } label: {
                                Label("delete", systemImage: "trash.fill")
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                    HStack {
                        Button {
                            //vm.newIncomeSource()
                            //sheet = .incomeSource
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                } header: {
                    Text("Income Sources")
                }
            }
            HStack {
                //Text(vm.getTotalIncome(), format: .number.rounded(increment: 0.01))
                //Text(vm.currency)
            }
            .font(.title2)
        }
    }
}

#Preview {
    let budget = BudgetEntity(context: DependencyResolver.preview.databaseManager().viewContext)
    return CategoryWizardPageView(vm: CategoryWizardPageViewModel(budget))
}
