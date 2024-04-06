//
//  BudgetWizardViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.04.24.
//

import Foundation


class BudgetWizardViewModel: ObservableObject {
    
    @Published var name: String
    @Published var currency: String
    @Published var type: PlanType
    @Published var dailyReminder: Date
    
    @Published var incomeSources: [IncomeSource]
    
    init() {
        self.name = "My Budget"
        self.currency = "USD"
        self.type = .mountly
        self.incomeSources = [
            IncomeSource(id: UUID(), name: "Salary", amount: 0, iconName: "case", createdAt: Date()),
            IncomeSource(id: UUID(), name: "Salary", amount: 0, iconName: "case", createdAt: Date())
        ]
        
        let components = DateComponents(hour: 20, minute: 0)
        self.dailyReminder = Calendar.current.date(from: components) ?? Date()
    }
    
    func getCurrencies() -> [String] {
        ["USD", "EUR", "AMD", "RUB"]
    }
    
    func createBudget() {
        
    }
    
}

