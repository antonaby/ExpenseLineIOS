//
//  MainWizardPageView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.04.24.
//

import SwiftUI

struct MainWizardPageView: View {
    
    @ObservedObject var vm: BudgetWizardViewModel
    @State var currencySheetOpen: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Basic")) {
                TextField("Name", text: $vm.name).padding([.top, .bottom], 5)
                Button {
                    currencySheetOpen.toggle()
                } label: {
                    HStack {
                        Text("Currency")
                        Spacer()
                        Text(vm.currency)
                    }
                    .foregroundColor(.black)
                }
            }
            .listRowSeparator(.hidden)
            Section(header: Text("Type")) {
                DatePicker("First Day",
                           selection: $vm.periodStartsAt,
                           in: Date().dateRangeFromBegingOfMonth(),
                           displayedComponents: [.date])
                DatePicker("Daily Reminder",
                           selection: $vm.dailyReminderAt,
                           displayedComponents: [.hourAndMinute])
            }
            .listRowSeparator(.hidden)
        }
        .sheet(isPresented: $currencySheetOpen) {
            CurrencySelectorSheet(currency: $vm.currency)
        }
    }
}

#Preview {
    let budget = BudgetEntity(context: DependencyResolver.preview.databaseManager().viewContext)
    budget.name = "Preview"
    budget.currency = "en_US"
    budget.planTypeValue = .mountly
    
    return MainWizardPageView(vm: BudgetWizardViewModel(budget, budgetService: DependencyResolver.preview.budgetService()))
        .environmentObject(DependencyResolver.preview)
}
