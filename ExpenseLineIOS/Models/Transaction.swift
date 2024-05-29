//
//  Space.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation

struct DaySpendings: Identifiable {
    
    var id: Int
    var date: Date
    var value: Decimal
    var limit: Decimal
    
}

struct SpenginsStat: Identifiable {
    
    var id: Int
    var date: Date
    var value: Decimal
    
}

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
