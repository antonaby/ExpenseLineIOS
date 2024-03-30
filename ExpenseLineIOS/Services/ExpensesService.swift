//
//  ExpensesService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 26.03.24.
//

import Foundation
import CoreData


enum ExpenseServiceError: Error, LocalizedError {
    
    case FetchError(msg: String, reason: Error?)
    case SaveError(msg: String, reason: Error?)
    
}

class ExpensesService {
    
    private let dm: DatabaseManager
    
    init(dm: DatabaseManager) {
        self.dm = dm
    }
    
    func getSpaces() throws -> [SpaceEntity] {
        let request = SpaceEntity.fetchRequest()
        
        do {
            return try dm.viewContext.fetch(request)
        } catch {
            throw ExpenseServiceError.FetchError(msg: "Failed to fetch spaces", reason: error)
        }
    }
    
    func getTotalAmount() -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ExpenseEntity")
        request.resultType = .dictionaryResultType
        
        let totalAmountExpressionDescription = NSExpressionDescription()
        totalAmountExpressionDescription.name = "totalAmount"
        totalAmountExpressionDescription.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
        totalAmountExpressionDescription.expressionResultType = .integer32AttributeType
        
        request.propertiesToFetch = [totalAmountExpressionDescription]
        
        do {
            let results = try dm.viewContext.fetch(request) as? [NSDictionary]
            if let dict = results, let first = dict.first {
                return Int(first["totalAmount"] as! Int32)
            }
        } catch {
            print("Error \(error.localizedDescription)")
            return 0
        }
        
        return 0
    }
    
    func addBudget(_ budget: Budget) {
        let budgetEntity = BudgetEntity(context: dm.viewContext)
        budgetEntity.id = budget.id
        budgetEntity.name = budget.name
        
        dm.save()
    }
    
    func addSpace(_ space: Space) {
        let spaceEntity = SpaceEntity(context: dm.viewContext)
        spaceEntity.id = space.id
        spaceEntity.name = space.name
        spaceEntity.iconName = space.iconName
        
        dm.save()
    }
    
    // TODO: add currency
    func addExpense(_ expense: Expense, space: SpaceEntity) throws {
        let expenseEntity = ExpenseEntity(context: dm.viewContext)
        expenseEntity.id = expense.id
        expenseEntity.name = expense.name
        expenseEntity.amount = Int32(expense.amount)
        expenseEntity.space = space
        
        dm.save()
    }
    
    func getSpaceById(_ id: UUID) throws -> SpaceEntity? {
        let request = SpaceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try dm.viewContext.fetch(request).first
        } catch {
            throw ExpenseServiceError.FetchError(msg: "Failed to fetch a space by id", reason: error)
        }
    }
    
}
