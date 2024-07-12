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
    private let analyticsService: AnalyticsService
    
    init(budgetService: BudgetService, analyticsService: AnalyticsService) {
        self.budgetService = budgetService
        self.analyticsService = analyticsService
        self.budgets = []
    }
    
    func loadBudgets() {
        do {
            budgets = try budgetService.getAllBudgets()
        } catch {
            logErrorEvent(error)
            print("Something went wrong: \(error)")
        }
    }
    
    func deleteBudget(_ budget: BudgetEntity) {
        do {
            try budgetService.deleteBudget(budget)
            try budgetService.save()
            budgets = try budgetService.getAllBudgets()
        } catch {
            logErrorEvent(error)
            print("Something went wrong: \(error)")
        }
    }
    
    private func logErrorEvent(_ error: Error) {
        analyticsService.logEvent(name: AnalyticsService.DATA_ERROR, params: ["place": "budget_list", "msg": "\(error)"])
    }
    
}
