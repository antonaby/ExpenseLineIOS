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
    case SaveError(msg: String, reason: Error?)
    
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
        entity.order = Int32.max
        
        return entity
    }
    
    func newTransactionEntity(_ budget: BudgetEntity) -> TransactionEntity {
        let entity = TransactionEntity(context: dm.viewContext)
        entity.id = UUID()
        entity.budget = budget
        
        return entity
    }
    
    func newNotificationEntity(_ budget: BudgetEntity) -> NotificationEntity {
        let entity = NotificationEntity(context: dm.viewContext)
        entity.id = UUID()
        entity.budget = budget
        
        return entity
    }
    
    func deleteCategory(_ category: PlanCategoryEntity, budget: BudgetEntity) {
        budget.removeFromCategories(category)
        dm.viewContext.delete(category)
    }
    
    func deleteTransaction(_ transaction: TransactionEntity, budget: BudgetEntity) {
        budget.removeFromTransactions(transaction)
        dm.viewContext.delete(transaction)
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
    
    func getPeriodByDate(for date: Date, budget: BudgetEntity) throws -> PeriodEntity {
        let budgetId = try getBudgetId(budget)
        
        let request = PeriodEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "budget.id == %@ AND startsAt <= %@ AND endsAt >= %@",
            budgetId as CVarArg, date as NSDate, date as NSDate)
        request.fetchLimit = 1
        
        do {
            if let period = try dm.viewContext.fetch(request).first {
                return period
            }
            
            return try createPeriod(for: date, budget: budget)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch budget periods", reason: error)
        }
    }
    
    func getOrCreateLastPeriod(_ budget: BudgetEntity) throws -> PeriodEntity {
        if let period = try getLastPeriod(budget) {
            return period
        }
        
        return try createPeriod(for: Date(), budget: budget)
    }
    
    private func createPeriod(for date: Date, budget: BudgetEntity) throws -> PeriodEntity {
        let entity = PeriodEntity(context: dm.viewContext)
        entity.id = UUID()
        entity.budget = budget
        
        let currentDate = date.addingTimeInterval(60) // Add 1 minute in case it's still the previous month
        entity.startsAt = currentDate.firstDayOfMonth()
        entity.endsAt = currentDate.lastDayOfMonth()
        
        do {
            try dm.sync()
        } catch {
            throw BudgetServiceError.SaveError(msg: "Failed to save period", reason: error)
        }
        
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
    
    func getNotificationsForCategory(_ category: PlanCategoryEntity) throws -> [NotificationEntity] {
        guard let categoryId = category.id else {
            throw BudgetServiceError.MissingDataError(msg: "No category id", reason: nil)
        }
        
        let request = NotificationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "category.id == %@ AND (enabled == true OR type == 0)", categoryId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        do {
            return try dm.viewContext.fetch(request)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch notifications for category", reason: error)
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
        
    func getTransaction(_ id: UUID) throws -> TransactionEntity {
        let request = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let transaction = try dm.viewContext.fetch(request).first {
                return transaction
            }
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch transactions by id", reason: error)
        }
        
        throw BudgetServiceError.FetchError(msg: "Failed to fetch transactions by id", reason: nil)
    }
    
    func getAllTransactions(_ period: PeriodEntity, budget: BudgetEntity) throws -> [TransactionEntity] {
        guard
            let starsAt = period.startsAt,
            let endsAt = period.endsAt,
            let budgetId = budget.id
        else {
            throw BudgetServiceError.MissingDataError(msg: "Some data is not ptovided", reason: nil)
        }
        
        let request = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "createdAt BETWEEN {%@, %@} AND budget.id == %@",
            starsAt as NSDate, endsAt as NSDate, budgetId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try dm.viewContext.fetch(request)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch transactions by budget id", reason: error)
        }
    }
    
    func searchTransactions(_ search: String, period: PeriodEntity, budget: BudgetEntity) throws -> [TransactionEntity] {
        guard
            let starsAt = period.startsAt,
            let endsAt = period.endsAt,
            let budgetId = budget.id
        else {
            throw BudgetServiceError.MissingDataError(msg: "Some data is not ptovided", reason: nil)
        }
        
        let request = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "createdAt BETWEEN {%@, %@} AND budget.id == %@ AND name CONTAINS[cd] %@",
            starsAt as NSDate, endsAt as NSDate, budgetId as CVarArg, search as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try dm.viewContext.fetch(request)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch transactions by budget id", reason: error)
        }
    }
    
    func getAllTransactionsForCategory(_ category: PlanCategoryEntity, period: PeriodEntity) throws -> [TransactionEntity] {
        guard
            let starsAt = period.startsAt,
            let endsAt = period.endsAt,
            let categoryId = category.id
        else {
            throw BudgetServiceError.MissingDataError(msg: "Some data is not ptovided", reason: nil)
        }
        
        let request = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "createdAt BETWEEN {%@, %@} AND category.id == %@",
            starsAt as NSDate, endsAt as NSDate, categoryId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try dm.viewContext.fetch(request)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch transactions for category", reason: error)
        }
    }
    
    func getSpendingsForCategories(_ period: PeriodEntity, budget: BudgetEntity, types: [CategoryType]) throws -> [CategorySpendings] {
        do {
            let categories = try getCategoriesOfBudget(budget, types: types)
            return try getSpendingsPerCategory(period, budget: budget, categories: categories)
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch dynamic category spendings", reason: error)
        }
    }
    
    func getSpendingsForPeriodByDay(_ period: PeriodEntity, budget: BudgetEntity, types: [CategoryType]) throws -> [SpenginsStat] {
        guard
            let starsAt = period.startsAt,
            let endsAt = period.endsAt,
            let budgetId = budget.id
        else {
            throw BudgetServiceError.MissingDataError(msg: "Some data is not ptovided", reason: nil)
        }
        
        do {
            let categories = try getCategoriesOfBudget(budget, types: types)
            let categoryIds = categories
                .filter { $0.id != nil }
                .map { $0.id! }
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TransactionEntity")
            request.resultType = .dictionaryResultType
            
            let day = NSExpressionDescription()
            day.name = "day"
            day.expression = NSExpression(format: "day")
            day.expressionResultType = .dateAttributeType
            
            let spendings = NSExpressionDescription()
            spendings.name = "spendings"
            spendings.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
            spendings.expressionResultType = .decimalAttributeType
            
            request.propertiesToFetch = [day, spendings]
            request.propertiesToGroupBy = ["day"]
            request.sortDescriptors = [NSSortDescriptor(key: "day", ascending: true)]
            request.predicate = NSPredicate(format: "createdAt BETWEEN {%@, %@} AND budget.id == %@ AND category.id IN %@ AND day != nil",
                                            starsAt as NSDate, endsAt as NSDate, budgetId as CVarArg, categoryIds as NSArray)
            
            let statResult = try dm.viewContext.fetch(request) as? [NSDictionary]
            var result: [SpenginsStat] = []
            if let dict = statResult {
                var i = 0
                for element in dict {
                    result.append(SpenginsStat(
                        id: i,
                        date: element["day"] as! Date,
                        value: element["spendings"] as! Decimal
                    ))
                    i += 1
                }
            }
            
            return result
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch daily spending for period", reason: error)
        }
    }
    
    func getSpendingsForLastNPeriods(for numberOfPeriods: Int, budget: BudgetEntity, types: [CategoryType]) throws -> [SpenginsStat] {
        let budgetId = try getBudgetId(budget)
        
        do {
            let categories = try getCategoriesOfBudget(budget, types: types)
            let categoryIds = categories.filter { $0.id != nil }.map { $0.id! }
            
            let periods = try getLastNPeriods(for: numberOfPeriods, budget: budget)
            let periodIds = periods.filter { $0.id != nil }.map { $0.id! }
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TransactionEntity")
            request.resultType = .dictionaryResultType
            
            let period = NSExpressionDescription()
            period.name = "period"
            period.expression = NSExpression(format: "period.startsAt")
            period.expressionResultType = .dateAttributeType
            
            let spendings = NSExpressionDescription()
            spendings.name = "spendings"
            spendings.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
            spendings.expressionResultType = .decimalAttributeType
            
            request.propertiesToFetch = [period, spendings]
            request.propertiesToGroupBy = ["period.startsAt"]
            request.sortDescriptors = [NSSortDescriptor(key: "period.startsAt", ascending: true)]
            request.predicate = NSPredicate(format: "budget.id == %@ AND category.id IN %@ AND period.id IN %@ AND period != nil",
                                            budgetId as CVarArg, categoryIds as NSArray, periodIds as NSArray)
            
            let statResult = try dm.viewContext.fetch(request) as? [NSDictionary]
            var result: [SpenginsStat] = []
            if let dict = statResult {
                var i = 0
                for element in dict {
                    result.append(SpenginsStat(
                        id: i,
                        date: element["period"] as! Date,
                        value: element["spendings"] as! Decimal
                    ))
                    i += 1
                }
            }
            
            return result
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch daily spending for period", reason: error)
        }
    }
    
    func getTotalOutcomeForPeriod(_ period: PeriodEntity, budget: BudgetEntity, types: [CategoryType]) throws -> Decimal {
        guard
            let starsAt = period.startsAt,
            let endsAt = period.endsAt,
            let budgetId = budget.id
        else {
            throw BudgetServiceError.MissingDataError(msg: "Some data is not ptovided", reason: nil)
        }
        
        let categories = try getCategoriesOfBudget(budget, types: types)
        if categories.isEmpty {
            return 0
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
        
        request.propertiesToFetch = [totalAmountExpressionDescription]
        request.predicate = NSPredicate(format: "createdAt BETWEEN {%@, %@} AND budget.id == %@ AND category.id IN %@",
                                        starsAt as NSDate, endsAt as NSDate, budgetId as CVarArg, categoryIds as NSArray)
        
        do {
            let results = try dm.viewContext.fetch(request) as? [NSDictionary]
            if let dict = results, let first = dict.first {
                return first["totalAmount"] as! Decimal
            }
        } catch {
            throw BudgetServiceError.FetchError(msg: "Failed to fetch total outcome", reason: error)
        }
        
        return 0
    }
    
    private func getLastNPeriods(for numberOfPeriods: Int, budget: BudgetEntity) throws -> [PeriodEntity] {
        let budgetId = try getBudgetId(budget)
        
        let request = PeriodEntity.fetchRequest()
        request.predicate = NSPredicate(format: "budget.id == %@", budgetId as CVarArg)
        request.fetchLimit = numberOfPeriods
        request.sortDescriptors = [NSSortDescriptor(key: "startsAt", ascending: false)]
        
        return try dm.viewContext.fetch(request)
    }
    
    private func getBudgetId(_ budget: BudgetEntity) throws -> UUID {
        if let id = budget.id {
            return id
        }
        
        throw BudgetServiceError.MissingDataError(msg: "Missing budget id", reason: nil)
    }
    
    private func getSpendingsPerCategory(_ period: PeriodEntity, budget: BudgetEntity, categories: [PlanCategoryEntity]) throws -> [CategorySpendings] {
        guard
            let starsAt = period.startsAt,
            let endsAt = period.endsAt,
            let budgetId = budget.id
        else {
            throw BudgetServiceError.MissingDataError(msg: "Some data is not ptovided", reason: nil)
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
    
}
