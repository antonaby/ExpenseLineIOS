//
//  HomeViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation


class BudgetViewModel: ObservableObject {
    
    @Published var bugget: BudgetEntity
    @Published var period: PeriodEntity
        
    private let budgetService: BudgetService
    
    init(budget: BudgetEntity, period: PeriodEntity, budgetService: BudgetService) {
        self.bugget = budget
        self.period = period
        self.budgetService = budgetService
    }
    
    func getRemaingBudget() -> Double {
        3000.3
    }
    
    func getCurrency() -> String {
        // TODO: add proper currency
        bugget.currency ?? "USD"
    }
    
    func getPeriodName() -> String {
        guard let starts = period.startsAt else { return "Unknown" }
        
        let month = Calendar.current.component(.month, from: starts)
        return Calendar.current.monthSymbols[month - 1]
    }
   
}
