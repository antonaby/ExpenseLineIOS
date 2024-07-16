//
//  SubscriptionService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 20.06.24.
//

import Foundation
import StoreKit


class SubscriptionLimitService: ObservableObject {
    
    private static let MAX_NUMBER_OF_BUDGETS = 1
    private static let MAX_NUMBER_OF_CATEGORIES = 15
    private static let MAX_NUMBER_OF_TRANSACTIONS = 60
    private static let MAX_NUMBER_OF_NOTIFICATIONS = 20
    
    private let dm: DatabaseManager
    private let analyticsService: AnalyticsService
    
    init(dm: DatabaseManager, analyticsService: AnalyticsService) {
        self.dm = dm
        self.analyticsService = analyticsService
    }
 
    func checkMaxBudgetCount() -> Bool {
        let request = BudgetEntity.fetchRequest()
        
        do {
            let numOfBudgets = try dm.viewContext.count(for: request)
            return numOfBudgets < SubscriptionLimitService.MAX_NUMBER_OF_BUDGETS
        } catch {
            logErrorEvent(error)
            print("Something went wront \(error)")
        }
        
        return true
    }
    
    func checkMaxCategoryCount(_ budget: BudgetEntity) -> Bool {
        return budget.allCategories.count < SubscriptionLimitService.MAX_NUMBER_OF_CATEGORIES
    }
    
    func checkMaxTransactionCount(period: PeriodEntity, budget: BudgetEntity) -> Bool {
        guard let budgetId = budget.id, let periodId = period.id else { return true }
        let request = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "budget.id == %@ AND period.id == %@", budgetId as CVarArg, periodId as CVarArg)
        do {
            let numOfTransactions = try dm.viewContext.count(for: request)
            return numOfTransactions < SubscriptionLimitService.MAX_NUMBER_OF_TRANSACTIONS
        } catch {
            logErrorEvent(error)
            print("Something went wront \(error)")
        }
        
        return true
    }
    
    func checkMaxNotificationCount(budget: BudgetEntity) -> Bool {
        guard let budgetId = budget.id else { return true }
        let request = NotificationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "budget.id == %@", budgetId as CVarArg)
        
        do {
            let numOfNotifications = try dm.viewContext.count(for: request)
            return numOfNotifications < SubscriptionLimitService.MAX_NUMBER_OF_NOTIFICATIONS
        } catch {
            logErrorEvent(error)
            print("Something went wront \(error)")
        }
        
        
        return true
    }
    
    private func logErrorEvent(_ error: Error) {
        analyticsService.logError(place: "sunscription_limit", error: error)
    }
    
}
