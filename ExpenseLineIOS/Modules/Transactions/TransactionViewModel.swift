//
//  TransactionViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 07.06.24.
//

import Foundation


class TransactionViewModel: ObservableObject {
    
    @Published var transaction: TransactionEntity
    
    var budget: BudgetEntity
    var currency: CurrencySymbol
    
    private let budgetService: BudgetService
    private let analyticsService: AnalyticsService
    
    init(transaction: TransactionEntity, budget: BudgetEntity, currency: CurrencySymbol,
         budgetService: BudgetService, analyticsService: AnalyticsService) {
        self.transaction = transaction
        self.budget = budget
        self.currency = currency
        self.budgetService = budgetService
        self.analyticsService = analyticsService
    }
    
    func reloadTransaction() {
        guard let id = transaction.id
        else {
            return
        }
        
        do {
            transaction = try budgetService.getTransaction(id)
        } catch {
            logErrorEvent(error)
            print("Something went wrong \(error)")
        }
    }
    
    private func logErrorEvent(_ error: Error) {
        analyticsService.logEvent(name: AnalyticsService.DATA_ERROR, params: ["place": "transaction", "msg": "\(error)"])
    }
    
}
