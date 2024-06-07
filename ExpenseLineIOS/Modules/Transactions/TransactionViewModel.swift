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
    private let currencyFormatter: NumberFormatter
    private let dateFormatter: DateFormatter
    
    init(transaction: TransactionEntity, budget: BudgetEntity, currency: CurrencySymbol, budgetService: BudgetService) {
        self.transaction = transaction
        self.budget = budget
        self.currency = currency
        self.budgetService = budgetService
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = currency.locale
        currencyFormatter.minimumFractionDigits = 0
        currencyFormatter.maximumFractionDigits = 2
        self.currencyFormatter = currencyFormatter
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.setLocalizedDateFormatFromTemplate("MM-dd-yyyy HH:mm")
        self.dateFormatter = dateFormatter
    }
    
    func formatAmount(_ amount: Decimal) -> String {
        if let fomatted = currencyFormatter.string(from: amount as NSDecimalNumber) {
            return fomatted
        }
        
        print("Error, amount: \(amount) can't be formatted") // TODO: send error event
        return "?"
    }
    
    func formatDate(_ date: Date?) -> String {
        if let currentDate = date {
            return dateFormatter.string(from: currentDate)
        }
        
        return "?"
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
