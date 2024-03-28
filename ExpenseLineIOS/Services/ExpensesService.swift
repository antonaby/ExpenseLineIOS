//
//  ExpensesService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 26.03.24.
//

import Foundation


enum ExpenseServiceError: Error, LocalizedError {
    
    case FetchError(msg: String, reason: Error?)
    case SaveError(msg: String, reason: Error?)
    
}

class ExpensesService {
    
    public static let shared = ExpensesService()
    
    init() {
        
    }
    
    func getSpaces() throws -> [Space] {
        let request = SpaceEntity.fetchRequest()
        
        do {
            let spaces = try DatabaseManager.shared.viewContext.fetch(request)
            return spaces.map { space in
                // TODO: check nil
                Space(id: space.id ?? UUID(), name: space.name ?? "No", iconName: space.iconName ?? "No")
            }
        } catch {
            throw ExpenseServiceError.FetchError(msg: "Failed to fetch spaces", reason: error)
        }
    }
    
    func getTotalAmount() -> Int {
        let request = SpaceEntity.fetchRequest()
        
        do {
            let spaces = try DatabaseManager.shared.viewContext.fetch(request)
            if spaces.isEmpty {
                return 0
            }
            
            let total = Int(spaces.reduce(0)  { r, e in
                r + e.totalExpenses
            })
            
            return total
        } catch {
            return 0
        }
    }
    
    func addSpace(_ space: Space) {
        let spaceEntity = SpaceEntity(context: DatabaseManager.shared.viewContext)
        spaceEntity.id = space.id
        spaceEntity.name = space.name
        spaceEntity.iconName = space.iconName
        
        DatabaseManager.shared.save()
    }
    
    // TODO: add currency
    func addExpense(_ expense: Expense) throws {
        let expenseEntity = ExpenseEntity(context: DatabaseManager.shared.viewContext)
        expenseEntity.id = expense.id
        expenseEntity.name = expense.name
        expenseEntity.amount = Int32(expense.amount)
        
        do {
            let space = try getSpaceById(expense.spaceId)
            expenseEntity.space = space
        } catch {
            throw ExpenseServiceError.SaveError(msg: "Failed to save expense", reason: error)
        }
        
        DatabaseManager.shared.save()
    }
    
    private func getSpaceById(_ id: UUID) throws -> SpaceEntity? {
        let request = SpaceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try DatabaseManager.shared.viewContext.fetch(request).first
        } catch {
            throw ExpenseServiceError.FetchError(msg: "Failed to fetch a space by id", reason: error)
        }
    }
    
}
