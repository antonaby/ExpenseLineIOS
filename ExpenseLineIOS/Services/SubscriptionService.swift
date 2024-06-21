//
//  SubscriptionService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 20.06.24.
//

import Foundation


class SubscriptionService: ObservableObject {
    
    private static let MAX_NUMBER_OF_BUDGETS = 1
    
    private let dm: DatabaseManager
    
    init(dm: DatabaseManager) {
        self.dm = dm
    }
    
    func getStandartSubsctiprionCost() -> String {
        "$4,99/month"
    }
 
    func checkMaxBudgetCount() -> Bool {
        if (checkSubcription()) {
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
    
    private func checkSubcription() -> Bool {
        return false
    }
    
}
