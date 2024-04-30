//
//  Space.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation

enum PlanCategoryType: Int, CaseIterable, Identifiable {
    
    case income = 1
    case outcomeFixed = 2
    case outcomePercent = 3
    
    var id: Self { self }
    
}

struct PlanCategory: Identifiable, Hashable {
    
    let id: UUID
    var name: String
    var amount: Double
    var percent: Double
    var iconName: String
    var type: PlanCategoryType
    var createdAt: Date
    
}

extension PlanCategoryEntity {
    
    var typeValue: PlanCategoryType {
        get {
            PlanCategoryType(rawValue: Int(self.type)) ?? .outcomePercent
        }
        set {
            self.type = Int64(newValue.rawValue)
        }
    }
    
    func amountAsString(_ symbol: String, delimiter: String, trailing: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = delimiter
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let formatted = formatter.string(from: NSNumber(floatLiteral: amount)) ?? "0"
        
        if trailing {
            return formatted + " " + symbol
        } else {
            return symbol + " " + formatted
        }
    }
    
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
    let totalAmount: Double
    let expectedAmount: Double
    let expectedPercent: Double
    
}

struct CategoryInfo: Identifiable {
    
    let id: UUID
    let entity: PlanCategoryEntity
    let spendings: CategorySpendings?
    
}
