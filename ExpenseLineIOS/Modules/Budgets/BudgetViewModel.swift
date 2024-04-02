//
//  HomeViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation


class BudgetViewModel: ObservableObject {
    
    @Published var spaces: [SpaceEntity]
    @Published var totalAmount: Int
    
    let bugget: BudgetEntity
    
    private let es: ExpensesService
    
    init(budget: BudgetEntity, es: ExpensesService) {
        self.bugget = budget
        self.es = es
        
        self.spaces = []
        self.totalAmount = 0
    }
    
    func loadSpaces() {
        guard let budgetId = bugget.id else { return }
        
        do {
            spaces = try es.getSpacesForBudget(budgetId)
        } catch {
            // TODO: show error
        }
    }
    
    func loadTotalAmount() {
        guard let budgetId = bugget.id else { return }
        
        totalAmount = es.getTotalAmount(budgetId)
    }
    
}
