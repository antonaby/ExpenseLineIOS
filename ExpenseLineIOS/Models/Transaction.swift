//
//  Space.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation

extension TransactionEntity {
    
    var nameValue: String {
        get {
            name ?? ""
        }
    }
    
    var amountValue: NSDecimalNumber {
        amount ?? NSDecimalNumber(value: 0)
    }
    
    var amountDecimal: Decimal {
        get {
            amountValue as Decimal
        }
        set {
            amount = newValue as NSDecimalNumber
        }
    }
    
    var createdAtValue: Date {
        get {
            createdAt ?? Date()
        }
    }
    
    func amountAsString(symbol: String, delimiter: String, trailing: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = delimiter
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let formatted = formatter.string(from: amountValue) ?? "0"
        
        if trailing {
            return formatted + " " + symbol
        } else {
            return symbol + " " + formatted
        }
    }
    
}


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
    var amount: Decimal
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
