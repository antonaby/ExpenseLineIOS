//
//  Space.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation

struct PlanCategory: Identifiable, Hashable {
    
    let id: UUID
    var name: String
    var amount: Double
    var percent: Int
    var iconName: String
    var createdAt: Date
    
}

struct Space: Identifiable, Hashable {
    
    let id: UUID
    let name: String
    let iconName: String
    
}
