//
//  BaseViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import Foundation


class BudgetListViewModel: ObservableObject {
    
    @Published var budgets: [BudgetEntity]
    
    private let budgetService: BudgetService
    
    init(budgetService: BudgetService) {
        self.budgetService = budgetService
        self.budgets = []
    }
    
    func loadBudgets() {
        do {
            budgets = try budgetService.getAllBudgets()
        } catch {
            // TODO: show error message
            print("Something went wrong: \(error)")
        }
    }
    
}
