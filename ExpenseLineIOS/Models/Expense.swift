//
//  Expense.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 26.03.24.
//

import Foundation


struct Expense: Identifiable, Hashable {
    
    let id: UUID
    let spaceId: UUID
    let name: String
    let amount: Int
    let currency: String
    
}
