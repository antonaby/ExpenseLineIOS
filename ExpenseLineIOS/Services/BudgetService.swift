//
//  BudgetService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 10.04.24.
//

import Foundation
import CoreData

enum BudgetServiceError: Error {
    
    case MissingDataError(msg: String, reason: Error?)
    case FetchError(msg: String, reason: Error?)
    
}

class BudgetService: ObservableObject {
    
    private let dm: DatabaseManager
    
    init(dm: DatabaseManager) {
        self.dm = dm
    }
    
    func newBudgetEntity() -> BudgetEntity {
        let entity = BudgetEntity(context: dm.viewContext)
        entity.id = UUID()
        
        return entity
    }
    
    func newCategoryEntity(_ budget: BudgetEntity) -> PlanCategoryEntity {
        let entity = PlanCategoryEntity(context: dm.viewContext)
        entity.id = UUID()
        entity.createdAt = Date()
        entity.budget = budget
        
        return entity
    }
    
    func newTransactionEntity(_ budget: BudgetEntity) -> TransactionEntity {
        let entity = TransactionEntity(context: dm.viewContext)
        entity.id = UUID()
        entity.budget = budget
        
        return entity
    }
    
    func deleteCategory(_ category: PlanCategoryEntity, budget: BudgetEntity) {
        budget.removeFromCategories(category)
        dm.viewContext.delete(category)
    }
    
    func deleteBudget(_ budget: BudgetEntity) {
        dm.viewContext.delete(budget)
    }
    
    func save() throws {
        try dm.sync()
    }
    
    func rollback() {
        dm.rollback()
    }
    
    func getLastPeriod(_ budget: BudgetEntity) throws -> PeriodEntity? {
        let budgetId = try getBudgetId(budget)
        
        let currentDate = Date()
        let request = PeriodEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "budget.id == %@ AND startsAt <= %@ AND endsAt >= %@",
            budgetId as CVarArg, currentDate as NSDate, currentDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "startsAt", ascending: false)]
        request.fetchLimit = 1
        
        do {
            return try dm.viewContext.fetch(request).first
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch budget periods", reason: error)
        }
    }
    
    func getOrCreateLastPeriod(_ budget: BudgetEntity) throws -> PeriodEntity {
        if let period = try getLastPeriod(budget) {
            return period
        }
    
        let entity = PeriodEntity(context: dm.viewContext)
        entity.id = UUID()
        entity.budget = budget
        
        let currentDate = Date().addingTimeInterval(60) // Add 1 minute in case it's still the previous month
        entity.startsAt = currentDate.firstDayOfMonth()
        entity.endsAt = currentDate.lastDayOfMonth()
        
        try dm.sync()
        
        return entity
    }
    
    func getBudgetPeriods(_ budget: BudgetEntity) throws -> [PeriodEntity] {
        let budgetId = try getBudgetId(budget)
        
        let request = PeriodEntity.fetchRequest()
        request.predicate = NSPredicate(format: "budget.id == %@", budgetId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "startsAt", ascending: false)]
        
        do {
            return try dm.viewContext.fetch(request)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch budget periods", reason: error)
        }
    }
    
    func getCategoriesOfBudget(_ budget: BudgetEntity, types: [CategoryType]) throws -> [PlanCategoryEntity] {
        let budgetId = try getBudgetId(budget)
        
        let request = PlanCategoryEntity.fetchRequest()
        let typesInts = types.map{ $0.rawValue }
        request.predicate = NSPredicate(format: "budget.id == %@ AND type IN %@", budgetId as CVarArg, typesInts)
        
        do {
            return try dm.viewContext.fetch(request)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch categories", reason: error)
        }
    }
    
    private func getBudgetId(_ budget: BudgetEntity) throws -> UUID {
        if let id = budget.id {
            return id
        }
        
        throw BudgetServiceError.MissingDataError(msg: "Missing budget id", reason: nil)
    }
        
    
    // TODO: Review
    func getAllTransactions(_ period: PeriodEntity, budget: BudgetEntity) throws -> [TransactionEntity] {
        guard
            let starsAt = period.startsAt,
            let endsAt = period.endsAt,
            let budgetId = budget.id
        else {
            return []
        }
        
        let request = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "createdAt BETWEEN {%@, %@} AND budget.id == %@",
            starsAt as NSDate, endsAt as NSDate, budgetId as CVarArg)
        
        do {
            return try dm.viewContext.fetch(request)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch transactions by budget id", reason: error)
        }
    }
    
    func getBudgetById(_ budgetId: UUID) throws -> BudgetEntity? {
        let request = BudgetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", budgetId as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try dm.viewContext.fetch(request).first
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch budget by id", reason: error)
        }
    }
    
    func getAllBudgets() throws -> [BudgetEntity] {
        let request = BudgetEntity.fetchRequest()
        
        do {
            return try dm.viewContext.fetch(request)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch budget by id", reason: error)
        }
    }
    
    func getTotalPlannedBudget(budget: BudgetEntity) throws -> Double {
        do {
            return try getPlannedAmount(budget: budget, type: .income)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to get planned income amount", reason: error)
        }
    }
    
    func spendingsForAllCategories(_ period: PeriodEntity, budget: BudgetEntity) throws -> [CategorySpendings] {
        do {
            let categories = try getCategoriesOfBudget(budget, types: [.outcomeFixed, .outcomePercent])
            return try spendingsPerCategory(period, budget: budget, categories: categories)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch dynamic category spendings", reason: error)
        }
    }
    
    func spendingsForFixedCategories(_ period: PeriodEntity, budget: BudgetEntity) throws -> [CategorySpendings] {
        do {
            let categories = try categoriesByType(budget: budget, type: .outcomeFixed)
            return try spendingsPerCategory(period, budget: budget, categories: categories)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch dynamic category spendings", reason: error)
        }
    }
    
    func spendingsForDynamicCategories(_ period: PeriodEntity, budget: BudgetEntity) throws -> [CategorySpendings] {
        do {
            let categories = try categoriesByType(budget: budget, type: .outcomePercent)
            return try spendingsPerCategory(period, budget: budget, categories: categories)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch dynamic category spendings", reason: error)
        }
    }
    
    private func categoriesByType(budget: BudgetEntity, type: CategoryType) throws -> [PlanCategoryEntity] {
        guard let budgetId = budget.id else { return [] }
        
        let request = PlanCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "budget.id == %@ AND type == %d", budgetId as CVarArg, type.rawValue as NSInteger)
        
        return try dm.viewContext.fetch(request)
    }
    
    private func spendingsPerCategory(_ period: PeriodEntity, budget: BudgetEntity, categories: [PlanCategoryEntity]) throws -> [CategorySpendings] {
        guard
            let starsAt = period.startsAt,
            let endsAt = period.endsAt,
            let budgetId = budget.id
        else {
            return []
        }
        
        let categoryIds = categories
            .filter { $0.id != nil }
            .map { $0.id! }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TransactionEntity")
        request.resultType = .dictionaryResultType
        
        let totalAmountExpressionDescription = NSExpressionDescription()
        totalAmountExpressionDescription.name = "totalAmount"
        totalAmountExpressionDescription.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
        totalAmountExpressionDescription.expressionResultType = .decimalAttributeType
        
        let categoryId = NSExpressionDescription()
        categoryId.name = "categoryId"
        categoryId.expression = NSExpression(format: "category.id")
        categoryId.expressionResultType = .UUIDAttributeType
        
        let categoryExpectedAmount = NSExpressionDescription()
        categoryExpectedAmount.name = "expectedAmount"
        categoryExpectedAmount.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "category.amount")])
        categoryExpectedAmount.expressionResultType = .decimalAttributeType
        
        let categoryExpectedPercent = NSExpressionDescription()
        categoryExpectedPercent.name = "expectedPercent"
        categoryExpectedPercent.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "category.percent")])
        categoryExpectedPercent.expressionResultType = .decimalAttributeType
        
        request.propertiesToFetch = [categoryId, categoryExpectedAmount, categoryExpectedPercent, totalAmountExpressionDescription]
        request.propertiesToGroupBy = ["category.id"]
        request.predicate = NSPredicate(
            format: "createdAt BETWEEN {%@, %@} AND budget.id == %@ AND category.id IN %@",
            starsAt as NSDate, endsAt as NSDate, budgetId as CVarArg, categoryIds as NSArray
        )
        
        let categories = try dm.viewContext.fetch(request) as? [NSDictionary]
        var result: [CategorySpendings] = []
        if let dict = categories {
            for element in dict {
                result.append(CategorySpendings(
                    id: element["categoryId"] as! UUID,
                    totalAmount: element["totalAmount"] as! Decimal,
                    expectedAmount: element["expectedAmount"] as! Decimal,
                    expectedPercent: element["expectedPercent"] as! Decimal
                ))
            }
        }
        
        return result
    }
    
    private func getPlannedAmount(budget: BudgetEntity, type: CategoryType, percent: Bool = false) throws -> Double {
        guard let budgetId = budget.id else { return 0 }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PlanCategoryEntity")
        request.resultType = .dictionaryResultType
        
        let totalAmountExpressionDescription = NSExpressionDescription()
        totalAmountExpressionDescription.name = "totalAmount"
        totalAmountExpressionDescription.expression = NSExpression(
            forFunction: "sum:",
            arguments: [NSExpression(forKeyPath: percent ? "percent" : "amount")])
        totalAmountExpressionDescription.expressionResultType = .doubleAttributeType
        
        request.propertiesToFetch = [totalAmountExpressionDescription]
        request.predicate = NSPredicate(format: "budget.id == %@ AND type == %d", budgetId as CVarArg, type.rawValue as NSInteger)
        
        let results = try dm.viewContext.fetch(request) as? [NSDictionary]
        if let dict = results, let first = dict.first {
            return first["totalAmount"] as! Double
        }
        
        return 0
    }
    
    func getTotalOutcomeForPeriod(_ period: PeriodEntity, budget: BudgetEntity) throws -> Double {
        guard 
            let starsAt = period.startsAt,
            let endsAt = period.endsAt,
            let budgetId = budget.id
        else {
            return 0
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TransactionEntity")
        request.resultType = .dictionaryResultType
        
        let totalAmountExpressionDescription = NSExpressionDescription()
        totalAmountExpressionDescription.name = "totalAmount"
        totalAmountExpressionDescription.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
        totalAmountExpressionDescription.expressionResultType = .doubleAttributeType
        
        request.propertiesToFetch = [totalAmountExpressionDescription]
        request.predicate = NSPredicate(format: "createdAt BETWEEN {%@, %@} AND budget.id == %@", starsAt as NSDate, endsAt as NSDate, budgetId as CVarArg)
        
        do {
            let results = try dm.viewContext.fetch(request) as? [NSDictionary]
            if let dict = results, let first = dict.first {
                return first["totalAmount"] as! Double
            }
        } catch {
            print("Error \(error.localizedDescription)")
            return 0
        }
        
        return 0
    }
    
}
