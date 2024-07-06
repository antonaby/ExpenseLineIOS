//
//  SubscriptionService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 20.06.24.
//

import Foundation
import StoreKit


class SubscriptionService: ObservableObject {
    
    private static let MAX_NUMBER_OF_BUDGETS = 1
    private static let MAX_NUMBER_OF_CATEGORIES = 15
    private static let MAX_NUMBER_OF_TRANSACTIONS = 60
    private static let MAX_NUMBER_OF_NOTIFICATIONS = 20
    
    private let dm: DatabaseManager
    
    init(dm: DatabaseManager) {
        self.dm = dm
    }
    
    func allProducts() async -> [Product] {
        do {
            let productIdentifiers = ["default_monthly_subscription"]
            return try await Product.products(for: productIdentifiers)
        } catch {
            print("Something went wrong \(error)")
            return []
        }
    }
    
    func buyProduct(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case let .success(.verified(transaction)):
                // Successful purhcase
                await transaction.finish()
            case let .success(.unverified(_, error)):
                // Successful purchase but transaction/receipt can't be verified
                // Could be a jailbroken phone
                print("Unverified purchase. Might be jailbroken. Error: \(error)")
                break
            case .pending:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                break
            case .userCancelled:
                // ^^^
                print("User Cancelled!")
                break
            @unknown default:
                print("Failed to purchase the product!")
                break
            }
        } catch {
            print("Failed to purchase the product!")
        }
    }
    
    func getStandartSubsctiprionCost() -> String {
        "$4,99/month"
    }
 
    func checkMaxBudgetCount() -> Bool {
        if checkSubcription() {
            return true
        }
        
        let request = BudgetEntity.fetchRequest()
        
        do {
            let numOfBudgets = try dm.viewContext.count(for: request)
            return numOfBudgets < SubscriptionService.MAX_NUMBER_OF_BUDGETS
        } catch {
            print("Something went wront \(error)")
        }
        
        return true
    }
    
    func checkMaxCategoryCount(_ budget: BudgetEntity) -> Bool {
        if checkSubcription() {
            return true
        }
        
        return budget.allCategories.count < SubscriptionService.MAX_NUMBER_OF_CATEGORIES
    }
    
    func checkMaxTransactionCount(period: PeriodEntity, budget: BudgetEntity) -> Bool {
        if checkSubcription() {
            return true
        }
        
        guard let budgetId = budget.id, let periodId = period.id else { return true }
        let request = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "budget.id == %@ AND period.id == %@", budgetId as CVarArg, periodId as CVarArg)
        do {
            let numOfTransactions = try dm.viewContext.count(for: request)
            return numOfTransactions < SubscriptionService.MAX_NUMBER_OF_TRANSACTIONS
        } catch {
            print("Something went wront \(error)")
        }
        
        return true
    }
    
    func checkMaxNotificationCount(budget: BudgetEntity) -> Bool {
        if checkSubcription() {
            return true
        }
        
        guard let budgetId = budget.id else { return true }
        let request = NotificationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "budget.id == %@", budgetId as CVarArg)
        
        do {
            let numOfNotifications = try dm.viewContext.count(for: request)
            return numOfNotifications < SubscriptionService.MAX_NUMBER_OF_NOTIFICATIONS
        } catch {
            print("Something went wront \(error)")
        }
        
        
        return true
    }
    
    private func checkSubcription() -> Bool {
        return false
    }
    
}
