//
//  BaseViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import Foundation


class BudgetListViewModel: ObservableObject {
    
    @Published var budgets: [BudgetEntity]
    
    private let es: ExpensesService
    
    init(es: ExpensesService) {
        self.es = es
        
        self.budgets = []
    }
    
    func loadBudgets() {
        do {
            budgets = try es.getBudgets()
        } catch {
            // TODO: show error
            print("Error \(error)")
        }
    }
    
}
