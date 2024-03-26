//
//  ExpensesService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 26.03.24.
//

import Foundation


class ExpensesService {
    
    public static let shared = ExpensesService()
    
    private var spaces: [Space]
    private var expenses: [Expense]
    private var totalAmount: Int
    
    init() {
        self.spaces = [
            Space(id: UUID(), name: "Home", iconName: "No"),
            Space(id: UUID(), name: "Garden", iconName: "No"),
            Space(id: UUID(), name: "Fun", iconName: "No"),
            Space(id: UUID(), name: "Car", iconName: "No"),
            Space(id: UUID(), name: "Vacation", iconName: "No"),
            Space(id: UUID(), name: "Other", iconName: "No"),
        ]
        self.expenses = []
        self.totalAmount = 0
    }
    
    func getSpaces() -> [Space] {
        return spaces
    }
    
    func getTotalAmount() -> Int {
        return totalAmount
    }
    
    // TODO: Save
    func addSpace(_ space: Space) {
        spaces.insert(space, at: 0)
    }
    
    // TODO: Save
    func addExpense(_ expense: Expense) {
        expenses.insert(expense, at: 0)
        totalAmount += expense.amount
    }
    
}
