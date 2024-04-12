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
    @Published var totalAmount: Double
        
    private let budgetService: BudgetService
    
    init(budget: BudgetEntity, period: PeriodEntity, budgetService: BudgetService) {
        self.bugget = budget
        self.period = period
        self.totalAmount = 0
        self.budgetService = budgetService
    }
    
    func updateTotalAmount() {
        do {
            totalAmount = try budgetService.getTotalOutcomeForPeriod(period, budget: bugget)
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
        }
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
