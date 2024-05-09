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
            Section {
                TextField("Name", text: $vm.name).padding([.top, .bottom], 5)
                Button {
                    currencySheetOpen.toggle()
                } label: {
                    HStack {
                        Text("Currency")
                        Spacer()
                        Text(vm.currency.code)
                            .bold()
                    }
                    .foregroundColor(.black)
                }
            }
            .listRowSeparator(.hidden)
            Section {
                DatePicker("First Day",
                           selection: $vm.periodStartsAt,
                           in: Date().dateRangeFromBegingOfMonth(),
                           displayedComponents: [.date])
                DatePicker("Daily Reminder",
                           selection: $vm.dailyReminderAt,
                           displayedComponents: [.hourAndMinute])
            }
            .listRowSeparator(.hidden)
            Section {
                CategoryListWizardView(vm: vm, types: [.income])
            }
        }
        .sheet(isPresented: $currencySheetOpen) {
            CurrencySelectorSheet(currency: $vm.currency)
        }
    }
}

#Preview {
    let dm = DependencyResolver.preview.databaseManager()
    let budget = BudgetEntity(context: dm.viewContext)
    budget.name = "Preview"
    budget.currency = "en_US"
    budget.planTypeValue = .mountly
    
    let category1 = PlanCategoryEntity(context: dm.viewContext)
    category1.id = UUID()
    category1.name = "Preview 1"
    category1.typeValue = .income
    category1.colorValue = .green
    category1.iconName = "case"
    category1.budget = budget
    category1.amountDecimal = 1000
    
    let category2 = PlanCategoryEntity(context: dm.viewContext)
    category2.id = UUID()
    category2.name = "Preview 2"
    category2.typeValue = .income
    category2.colorValue = .green
    category2.iconName = "globe"
    category2.budget = budget
    category2.amountDecimal = 1000000
    
    return MainWizardPageView(
        vm: BudgetWizardViewModel(
            budget, 
            budgetService: DependencyResolver.preview.budgetService(),
            dataService: DependencyResolver.preview.dataService()
        ))
        .environmentObject(DependencyResolver.preview)
}
