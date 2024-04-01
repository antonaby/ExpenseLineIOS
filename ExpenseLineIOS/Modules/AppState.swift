//
//  AppState.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import Foundation


class AppState: ObservableObject {
    
    @Published var budget: BudgetEntity?
    
    func selectBudget(_ budget: BudgetEntity) {
        self.budget = budget
    }
    
}
