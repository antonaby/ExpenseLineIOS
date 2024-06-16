//
//  CategoryViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 16.05.24.
//

import Foundation


class CategoryViewModel: ObservableObject {
    
    @Published var transactions: [TransactionEntity] = []
    @Published var totalAmount: Decimal = 0
    @Published var category: PlanCategoryEntity
    @Published var notifications: [NotificationEntity] = []
    
    var budget: BudgetEntity
    var currency: CurrencySymbol
    var period: PeriodEntity
    
    private var budgetService: BudgetService
    private var currencyFormatter: NumberFormatter
    private var dateFormatter: DateFormatter
    private var percentFormatter: NumberFormatter
    
    var name: String {
        category.nameValue
    }
    
    init(category: PlanCategoryEntity, period: PeriodEntity, budget: BudgetEntity, currency: CurrencySymbol, budgetService: BudgetService) {
        self.category = category
        self.period = period
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
        
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale(identifier: currency.id)
        percentFormatter.minimumFractionDigits = 0
        percentFormatter.maximumFractionDigits = 2
        self.percentFormatter = percentFormatter
    }
    
    func percentSpent() -> Double {
        if totalAmount <= 0 {
            return 0
        }
        
        if category.typeValue == .outcomeFixed {
            if category.amountDecimal <= 0 {
                return 1
            }
            let percent = totalAmount / category.amountDecimal
            return Double(truncating: percent as NSNumber)
        } else if category.typeValue == .outcomePercent {
            if category.percentDecimal <= 0 {
                return 1
            }
                        
            let percent = totalAmount / getPlannedAmountFromPercent()
            return Double(truncating: percent as NSNumber)
        }
        
        return 0
    }
    
    func getPlannedAmountFromPercent() -> Decimal {
        let income = budget.totalAmountForCategoryType(.income)
        return income * category.percentDecimal
    }
    
    func loadTransactions() {
        do {
            transactions = try budgetService.getAllTransactionsForCategory(category, period: period)
            totalAmount = transactions.reduce(0) { $0 + $1.amountDecimal }
        } catch {
            // TODO: handle error
            print("Something went wrong \(error)")
        }
    }
    
    func loadNotifications() {
        do {
            notifications = try budgetService.getNotificationsForCategory(category)
        } catch {
            // TODO: handle error
            print("Something went wrong \(error)")
        }
    }
    
    func updateCategory(_ category: PlanCategoryEntity) {
        self.category = category
        loadTransactions()
    }
    
    func deleteCategory(_ category: PlanCategoryEntity) {
        do {
            budgetService.deleteCategory(category, budget: budget)
            try budgetService.save()
        } catch {
            // TODO: handle error
            print("Somwthing went wrong \(error)")
        }
    }
    
    func deleteTransaction(_ transaction: TransactionEntity) {
        do {
            budgetService.deleteTransaction(transaction, budget: budget)
            try budgetService.save()
        } catch {
            // TODO: handle error
            print("Somwthing went wrong \(error)")
        }
        loadTransactions()
    }
    
    func formatAmount(_ amount: Decimal) -> String {
        if let fomatted = currencyFormatter.string(from: amount as NSDecimalNumber) {
            return fomatted
        }
        
        print("Error, amount: \(amount) can't be formatted") // TODO: send error event
        return "?"
    }
    
    func formatPercent(_ percent: Decimal) -> String {
        if let fomatted = percentFormatter.string(from: percent as NSDecimalNumber) {
            return fomatted
        }
        
        print("Error, amount: \(percent) can't be formatted") // TODO: send error event
        return "?"
    }
    
    func formatDate(_ date: Date?) -> String {
        if let currentDate = date {
            return dateFormatter.string(from: currentDate)
        }
        
        return "?"
    }
    
}
