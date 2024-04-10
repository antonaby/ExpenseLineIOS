//
//  BudgetService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 10.04.24.
//

import Foundation


class BudgetService {
    
    private let dm: DatabaseManager
    
    init(dm: DatabaseManager) {
        self.dm = dm
    }
    
    func createBudget(budget: Budget, categories: [PlanCategory]) throws {
        let entity = BudgetEntity(context: dm.viewContext)
        entity.id = budget.id
        entity.name = budget.name
        entity.currency = budget.currency
        entity.planTypeValue = budget.type
        for category in categories {
            entity.addToCategories(getPlanCategoryEntity(category))
        }
        
        try dm.sync()
    }
    
    private func getPlanCategoryEntity(_ category: PlanCategory) -> PlanCategoryEntity {
        let entity = PlanCategoryEntity(context: dm.viewContext)
        entity.id = category.id
        entity.name = category.name
        entity.amount = category.amount
        entity.percent = category.percent
        entity.iconName = category.iconName
        entity.typeValue = category.type
        entity.createdAt = category.createdAt
                
        return entity
    }
    
    
    
}
