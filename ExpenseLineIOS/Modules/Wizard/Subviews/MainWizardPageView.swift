//
//  MainWizardPageView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.04.24.
//

import SwiftUI
import Combine

class MainWizardPageViewModel: ObservableObject {
    
    @Published var name: String
    @Published var currency: String
    @Published var type: PlanType
    @Published var dailyReminder: Date
    @Published var periodStartsAt: Date
    
    init() {
        self.name = ""
        self.currency = "USD"
        self.type = .mountly
        self.dailyReminder = Date()
        
        let periodComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        self.periodStartsAt = Calendar.current.date(from: periodComponents)!
    }
    
    func getCurrencies() -> [String] {
        return ["USD", "EUR", "RUB", "AMD"]
    }
    
    func getDateRange() -> ClosedRange<Date> {
        let periodComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        let firstDay = Calendar.current.date(from: periodComponents)!
        
        return firstDay ... Date()
    }
    
}

struct MainWizardPageView: View {
    
    @ObservedObject var vm: MainWizardPageViewModel
    
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
                           selection: $vm.dailyReminder,
                           displayedComponents: [.hourAndMinute])
            }
        }
    }
}

#Preview {
    MainWizardPageView(vm: MainWizardPageViewModel())
}
