//
//  AppState.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import Foundation


class AppState: ObservableObject {
    
    @Published var showError: Bool?
    @Published var budget: BudgetEntity?

    private let budgetService: BudgetService
    private let settingsService: SettingsService
    
    init(budgetService: BudgetService, settingsService: SettingsService) {
        self.budgetService = budgetService
        self.settingsService = settingsService
    }
    
    func selectBudget(_ budget: BudgetEntity) {
        self.budget = budget
        settingsService.setBudgetId(budget.id)
    }
    
    func unselectBudget() {
        budget = nil
        settingsService.setBudgetId(nil)
    }
    
    func loadBudget() {
        budget = getBudget()
    }

    private func getBudget() -> BudgetEntity? {
        if let budgetId = settingsService.getBudgetId() {
            do {
                return try budgetService.getBudgetById(budgetId)
            } catch {
                // TODO: show error
                print("Can't fetch budget info: \(error)")
            }
        }
        
        return nil
    }
    
}
