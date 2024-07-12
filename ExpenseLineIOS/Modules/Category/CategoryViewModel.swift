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
    private var notificationService: NotificationService
    private var analyticsService: AnalyticsService
    
    var name: String {
        category.nameValue
    }
    
    init(category: PlanCategoryEntity, period: PeriodEntity, budget: BudgetEntity, currency: CurrencySymbol, 
         budgetService: BudgetService, notificationService: NotificationService, analyticsService: AnalyticsService) {
        self.category = category
        self.period = period
        self.budget = budget
        self.currency = currency
        self.budgetService = budgetService
        self.notificationService = notificationService
        self.analyticsService = analyticsService
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
            logErrorEvent(error)
            print("Something went wrong \(error)")
        }
    }
    
    func loadNotifications() {
        do {
            notifications = try notificationService.getNotificationsForToday(category: category, showNoNotifications: true)
        } catch {
            logErrorEvent(error)
            print("Something went wrong \(error)")
        }
    }
    
    func updateCategory(_ category: PlanCategoryEntity) {
        self.category = category
        loadTransactions()
    }
    
    func deleteCategory(_ category: PlanCategoryEntity) {
        do {
            try budgetService.deleteCategoryWithNotifications(category, budget: budget)
            try budgetService.save()
        } catch {
            logErrorEvent(error)
            print("Somwthing went wrong \(error)")
        }
    }
    
    func deleteTransaction(_ transaction: TransactionEntity) {
        do {
            budgetService.deleteTransaction(transaction, budget: budget)
            try budgetService.save()
        } catch {
            logErrorEvent(error)
            print("Somwthing went wrong \(error)")
        }
        loadTransactions()
    }
    
    private func logErrorEvent(_ error: Error) {
        analyticsService.logEvent(name: AnalyticsService.DATA_ERROR, params: ["place": "category", "msg": "\(error)"])
    }
    
}
