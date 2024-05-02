//
//  Space.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation


// TODO: remove
struct PlanCategory: Identifiable, Hashable {
    
    let id: UUID
    var name: String
    var amount: Decimal
    var percent: Decimal
    var iconName: String
    var type: CategoryType
    var createdAt: Date
    
}

struct Period: Identifiable, Hashable {
    
    let id: UUID
    var startsAt: Date
    var endsAt: Date
    
}

struct Transaction: Identifiable, Hashable {
    
    let id: UUID
    var name: String
    var amount: Double
    var createdAt: Date
    
}

struct CategorySpendings: Identifiable {
    
    let id: UUID
    let totalAmount: Decimal
    let expectedAmount: Decimal
    let expectedPercent: Decimal
    
}

struct CategoryInfo: Identifiable {
    
    let id: UUID
    let entity: PlanCategoryEntity
    let spendings: CategorySpendings?
    
}
