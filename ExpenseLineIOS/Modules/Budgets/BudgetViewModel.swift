//
//  HomeViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation


class BudgetViewModel: ObservableObject {
    
    @Published var budget: BudgetEntity
    @Published var period: PeriodEntity
    @Published var totalDynamicAmount: Double
    @Published var plannedBudget: Double
        
    private let budgetService: BudgetService
    
    init(budget: BudgetEntity, period: PeriodEntity, budgetService: BudgetService) {
        self.budget = budget
        self.period = period
        self.totalDynamicAmount = 0
        self.plannedBudget = 0
        self.budgetService = budgetService
    }
        
    func getCurrency() -> String {
        // TODO: add proper currency
        budget.currency ?? "USD"
    }
    
    func getPeriodName() -> String {
        guard let starts = period.startsAt else { return "Unknown" }
        
        let month = Calendar.current.component(.month, from: starts)
        return Calendar.current.monthSymbols[month - 1]
    }
    
    func updateSpendingPerCategory() {
        do {
            plannedBudget = try budgetService.getTotalPlannedBudget(budget: budget)
            let result = try budgetService.spendingsForDynamicCategories(period, budget: budget)
            totalDynamicAmount = result.reduce(0) { $0 + $1.totalAmount }
        } catch {
            // TODO: shopw error
            print("Error \(error)")
        }
    }
   
}
