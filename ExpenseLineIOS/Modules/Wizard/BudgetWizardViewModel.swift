//
//  BudgetWizardViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.04.24.
//

import Foundation

enum DataEditOp {
    case none
    case create
    case edit
    case delete
}

class BudgetWizardViewModel: ObservableObject {
    
    @Published var name: String
    @Published var currency: String
    @Published var type: PlanType
    @Published var dailyReminder: Date
    
    @Published var incomeSources: [IncomeSource]
    @Published var selectedIncomeSource: IncomeSource
    @Published var incomeSourceOp: DataEditOp
    
    init() {
        self.name = "My Budget"
        self.currency = "USD"
        self.type = .mountly
        self.incomeSources = [
            IncomeSource(id: UUID(), name: "Salary", amount: 0, iconName: "case", createdAt: Date())
        ]
        
        self.selectedIncomeSource = IncomeSource(id: UUID(), name: "My Income", amount: 0, iconName: "case", createdAt: Date())
        self.incomeSourceOp = .none
        
        let components = DateComponents(hour: 20, minute: 0)
        self.dailyReminder = Calendar.current.date(from: components) ?? Date()
    }
    
    func getCurrencies() -> [String] {
        ["USD", "EUR", "AMD", "RUB"]
    }
    
    func createBudget() {
        
    }
    
    func selectIncomeSource(_ source: IncomeSource, op: DataEditOp) {
        selectedIncomeSource = source
        incomeSourceOp = op
    }
    
    func newIncomeSource() {
        selectedIncomeSource = IncomeSource(id: UUID(), name: "My Income", amount: 0, iconName: "case", createdAt: Date())
        incomeSourceOp = .create
    }
    
    func performEditOps() {
        switch incomeSourceOp {
        case .create:
            incomeSources.append(selectedIncomeSource)
        case .edit:
            updateIncomeSource()
        case .delete:
            deleteIncomeSource()
        case .none: 
            break
        }
        
        incomeSourceOp = .none
    }
    
    func updateIncomeSource() {
        if let source = incomeSources.enumerated().filter({ $0.element.id == selectedIncomeSource.id }).first {
            incomeSources[source.offset] = selectedIncomeSource
        }
    }
    
    func deleteIncomeSource() {
        if let source = incomeSources.enumerated().filter({ $0.element.id == selectedIncomeSource.id }).first {
            incomeSources.remove(at: source.offset)
        }
    }
    
}

