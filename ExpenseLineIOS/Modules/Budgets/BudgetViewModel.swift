//
//  HomeViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation


class BudgetViewModel: ObservableObject {
    
    let bugget: BudgetEntity
    
    private let budgetService: BudgetService
    
    init(budget: BudgetEntity, budgetService: BudgetService) {
        self.bugget = budget
        self.budgetService = budgetService
    }
   
}
