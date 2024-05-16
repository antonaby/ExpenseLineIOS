//
//  CategoryViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 16.05.24.
//

import Foundation


class CategoryViewModel: ObservableObject {
    
    @Published var transactions: [TransactionEntity] = []
    
    private var category: PlanCategoryEntity
    private var period: PeriodEntity
    private var budgetService: BudgetService
    private var currencyFormatter: NumberFormatter
    private var dateFormatter: DateFormatter
    
    var name: String {
        category.nameValue
    }
    
    init(category: PlanCategoryEntity, period: PeriodEntity, currency: CurrencySymbol, budgetService: BudgetService) {
        self.category = category
        self.period = period
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
    
    func loadTransactions() {
        do {
            transactions = try budgetService.getAllTransactionsForCategory(category, period: period)
        } catch {
            // TODO: handle error
            print("Something went wrong \(error)")
        }
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
    
}
