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
    
    init(transaction: TransactionEntity, budget: BudgetEntity, currency: CurrencySymbol, budgetService: BudgetService) {
        self.transaction = transaction
        self.budget = budget
        self.currency = currency
        self.budgetService = budgetService
    }
    
    func reloadTransaction() {
        guard let id = transaction.id
        else {
            print("Transaction has no id") // TODO: handle error
            return
        }
        
        do {
            transaction = try budgetService.getTransaction(id)
        } catch {
            // TODO: handle error
            print("Something went wrong \(error)")
        }
    }
}
