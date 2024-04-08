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
    
    @Published var incomeSources: [PlanCategory]
    @Published var selectedIncomeSource: PlanCategory
    @Published var incomeSourceOp: DataEditOp
    
    @Published var fixedOutcomes: [PlanCategory]
    @Published var selectedFixedOutcome: PlanCategory
    @Published var fixedOutcomeOp: DataEditOp
    
    @Published var dailyOutcomes: [PlanCategory]
    @Published var selectedDailyOutcome: PlanCategory
    @Published var dailyOutcomeOp: DataEditOp
    
    init() {
        self.name = "My Budget"
        self.currency = "USD"
        self.type = .mountly
        
        self.incomeSources = [
            PlanCategory(id: UUID(), name: "Salary", amount: 0, percent: 0, iconName: "case", createdAt: Date())
        ]
        self.selectedIncomeSource = PlanCategory(id: UUID(), name: "My Income", amount: 0, percent: 0, iconName: "case", createdAt: Date())
        self.incomeSourceOp = .none
        
        self.fixedOutcomes = [
            PlanCategory(id: UUID(), name: "Rent", amount: 0, percent: 0, iconName: "house", createdAt: Date()),
            PlanCategory(id: UUID(), name: "Internet", amount: 0, percent: 0, iconName: "globe", createdAt: Date()),
            PlanCategory(id: UUID(), name: "Phone", amount: 0, percent: 0, iconName: "phone", createdAt: Date())
        ]
        self.selectedFixedOutcome = PlanCategory(id: UUID(), name: "My fixed outcome", amount: 0, percent: 0, iconName: "case", createdAt: Date())
        self.fixedOutcomeOp = .none
        
        self.dailyOutcomes = [
            PlanCategory(id: UUID(), name: "Groceries", amount: 0, percent: 0, iconName: "cart", createdAt: Date()),
            PlanCategory(id: UUID(), name: "Coffee", amount: 0, percent: 0, iconName: "cup.and.saucer", createdAt: Date())
        ]
        self.selectedDailyOutcome = PlanCategory(id: UUID(), name: "My daily expense", amount: 0, percent: 0, iconName: "car", createdAt: Date())
        self.dailyOutcomeOp = .none
        
        let components = DateComponents(hour: 20, minute: 0)
        self.dailyReminder = Calendar.current.date(from: components) ?? Date()
    }
    
    func getTotalIncomeAsString() -> String {
        let total = incomeSources.reduce(0) { $0 + $1.amount }
        return String(format: "%.2f", total)
    }
    
    func getTotalFixedOutcomeAsString() -> String {
        let total = fixedOutcomes.reduce(0) { $0 + $1.amount }
        return String(format: "%.2f", total)
    }
    
    func getTotalDailyOutcomeAsString() -> String {
        let total = dailyOutcomes.reduce(0) { $0 + $1.amount }
        return String(format: "%.2f", total)
    }
    
    func remainingAsString() -> String {
        let income = incomeSources.reduce(0) { $0 + $1.amount }
        let outcome = fixedOutcomes.reduce(0) { $0 + $1.amount }
        
        return String(format: "%.2f", income - outcome)
    }
    
    func getCurrencies() -> [String] {
        ["USD", "EUR", "AMD", "RUB"]
    }
    
    func createBudget() {
        
    }
    
    func selectDailyOutcome(_ outcome: PlanCategory, op: DataEditOp) {
        selectedDailyOutcome = outcome
        dailyOutcomeOp = op
    }
    
    func newDailyOutcome() {
        selectedDailyOutcome = PlanCategory(id: UUID(), name: "My daily expense", amount: 0, percent: 0, iconName: "car", createdAt: Date())
        dailyOutcomeOp = .create
    }
    
    func selectFixedOutcome(_ outcome: PlanCategory, op: DataEditOp) {
        selectedFixedOutcome = outcome
        fixedOutcomeOp = op
    }
    
    func newFixedOutcome() {
        selectedFixedOutcome = PlanCategory(id: UUID(), name: "My fixed outcome", amount: 0, percent: 0, iconName: "case", createdAt: Date())
        fixedOutcomeOp = .create
    }
    
    func selectIncomeSource(_ source: PlanCategory, op: DataEditOp) {
        selectedIncomeSource = source
        incomeSourceOp = op
    }
    
    func newIncomeSource() {
        selectedIncomeSource = PlanCategory(id: UUID(), name: "My Income", amount: 0, percent: 0, iconName: "case", createdAt: Date())
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
        
        switch fixedOutcomeOp {
        case .create:
            fixedOutcomes.append(selectedFixedOutcome)
        case .edit:
            updateFixedOutcome()
        case .delete:
            deleteFixedOutcome()
        case .none:
            break
        }
        
        fixedOutcomeOp = .none
        
        switch dailyOutcomeOp {
        case .create:
            dailyOutcomes.append(selectedDailyOutcome)
        case .edit:
            updateDailyOutcome()
        case .delete:
            deleteDailyOutcome()
        case .none:
            break
        }
        
        dailyOutcomeOp = .none
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
    
    func updateFixedOutcome() {
        if let source = fixedOutcomes.enumerated().filter({ $0.element.id == selectedFixedOutcome.id }).first {
            fixedOutcomes[source.offset] = selectedFixedOutcome
        }
    }
    
    func deleteFixedOutcome() {
        if let source = fixedOutcomes.enumerated().filter({ $0.element.id == selectedFixedOutcome.id }).first {
            fixedOutcomes.remove(at: source.offset)
        }
    }
    
    func updateDailyOutcome() {
        if let source = dailyOutcomes.enumerated().filter({ $0.element.id == selectedDailyOutcome.id }).first {
            dailyOutcomes[source.offset] = selectedDailyOutcome
        }
    }
    
    func deleteDailyOutcome() {
        if let source = dailyOutcomes.enumerated().filter({ $0.element.id == selectedDailyOutcome.id }).first {
            dailyOutcomes.remove(at: source.offset)
        }
    }
    
}

