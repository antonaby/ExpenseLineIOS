//
//  BudgetService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 10.04.24.
//

import Foundation

enum BudgetServiceError: Error {
    
    case FetchError(msg: String, reason: Error?)
    
}


class BudgetService {
    
    private let dm: DatabaseManager
    
    init(dm: DatabaseManager) {
        self.dm = dm
    }
    
    func getOrCreateLastPeriod(_ budgetId: UUID) throws -> PeriodEntity {
        if let period = try getLastPeriod(budgetId) {
            return period
        }
    
        let entity = PeriodEntity(context: dm.viewContext)
        entity.id = UUID()
        
        let startComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        let periodStartsAt = Calendar.current.date(from: startComponents)!
        entity.startsAt = periodStartsAt
        
        var endComponents = DateComponents()
        endComponents.month = 1
        endComponents.second = -1
        entity.endstAt = Calendar.current.date(byAdding: endComponents, to: periodStartsAt)!
        
        try dm.sync()
        
        return entity
    }
    
    func getLastPeriod(_ budgetId: UUID) throws -> PeriodEntity? {
        let request = PeriodEntity.fetchRequest()
        request.predicate = NSPredicate(format: "budget.id == %@", budgetId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "startsAt", ascending: false)]
        request.fetchLimit = 1
        
        do {
            return try dm.viewContext.fetch(request).first
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch budget periods", reason: error)
        }
    }
    
    func getBudgetPeriods(_ budgetId: UUID) throws -> [PeriodEntity] {
        let request = PeriodEntity.fetchRequest()
        request.predicate = NSPredicate(format: "budget.id == %@", budgetId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "startsAt", ascending: false)]
        
        do {
            return try dm.viewContext.fetch(request)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch budget periods", reason: error)
        }
    }
    
    func createBudget(budget: Budget, period: Period, categories: [PlanCategory]) throws {
        let entity = BudgetEntity(context: dm.viewContext)
        entity.id = budget.id
        entity.name = budget.name
        entity.currency = budget.currency
        entity.planTypeValue = budget.type
        entity.addToPeriods(getPeriodEntity(period))
        for category in categories {
            entity.addToCategories(getPlanCategoryEntity(category))
        }
        
        try dm.sync()
    }
    
    private func getPeriodEntity(_ period: Period) -> PeriodEntity {
        let entity = PeriodEntity(context: dm.viewContext)
        entity.id = period.id
        entity.startsAt = period.startsAt
        entity.endstAt = period.endsAt
        
        return entity
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
