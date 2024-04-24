//
//  MainWizardPageView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.04.24.
//

import SwiftUI

struct MainWizardPageView: View {
    
    @ObservedObject var vm: BudgetWizardViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Basic")) {
                TextField("Name", text: $vm.name).padding([.top, .bottom], 5)
            }
            Section(header: Text("Type")) {
                Picker("Currency", selection: $vm.currency) {
                    ForEach(vm.getCurrencies(), id: \.self) { currency in
                        Text(currency)
                    }
                }
                Picker("Type", selection: $vm.type) {
                    ForEach(PlanType.allCases) { type in
                        Text("\(type)")
                    }
                }
                DatePicker("Period Starts at",
                           selection: $vm.periodStartsAt,
                           in: vm.getDateRange(),
                           displayedComponents: [.date])
            }
            Section(header: Text("Reminder")) {
                DatePicker("Daily reminder",
                           selection: $vm.dailyReminderAt,
                           displayedComponents: [.hourAndMinute])
            }
        }
    }
}

#Preview {
    let budget = BudgetEntity(context: DependencyResolver.preview.databaseManager().viewContext)
    budget.name = "Preview"
    budget.currency = "USD"
    budget.planTypeValue = .mountly
    
    return MainWizardPageView(vm: BudgetWizardViewModel(budget, budgetService: DependencyResolver.preview.budgetService()))
}
