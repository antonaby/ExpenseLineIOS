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
            }
            Section(header: Text("Reminder")) {
                DatePicker("Daily reminder",
                           selection: $vm.dailyReminder,
                           displayedComponents: [.hourAndMinute])
                DatePicker("Period Starts at",
                           selection: $vm.periodStartsAt,
                           in: vm.getDateRange(),
                           displayedComponents: [.date])
            }
        }
    }
}

#Preview {
    do {
        let vm = try DependencyResolver.preview.budgetWizzardViewModel()
        return MainWizardPageView(vm: vm)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
