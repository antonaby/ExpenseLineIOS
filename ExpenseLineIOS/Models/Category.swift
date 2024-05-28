//
//  Category.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.05.24.
//

import Foundation
import SwiftUI

enum CategoryType: Int, CaseIterable, Identifiable {
    
    case income = 1
    case outcomeFixed = 2
    case outcomePercent = 3
    
    var id: Self { self }
    
}

struct CategoryTemplate: Identifiable {
    
    var id: String
    var iconName: String
    
}

struct CategoryTemplateType: Identifiable {
    
    var id: String
    var type: CategoryType
    var templates: [CategoryTemplate]
    
}

struct CategorySpendings: Identifiable {
    
    let id: UUID
    let totalAmount: Decimal
    let expectedAmount: Decimal
    let expectedPercent: Decimal
    
}

struct CategoryData: Identifiable {
    
    let id: UUID
    let entity: PlanCategoryEntity
    let spendings: CategorySpendings
    
}

extension PlanCategoryEntity {
    
    var nameValue: String {
        get {
            name ?? ""
        }
    }
    
    var iconNameValue: String {
        get {
            iconName ?? "question"
        }
    }
    
    var typeValue: CategoryType {
        get {
            CategoryType(rawValue: Int(self.type)) ?? .outcomePercent
        }
        set {
            self.type = Int32(newValue.rawValue)
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
    
    var percentValue: NSDecimalNumber {
        percent ?? NSDecimalNumber(value: 0)
    }
    
    var percentDecimal: Decimal {
        get {
            percentValue as Decimal
        }
        set {
            percent = newValue as NSDecimalNumber
        }
    }
    
    var percentDecimalFraction: Decimal {
        get {
            percentValue as Decimal * 100
        }
        set {
            percent = newValue / 100 as NSDecimalNumber
        }
    }
    
    var colorValue: Color {
        get {
            if let value = color {
                return Color(hex: value) ?? .green
            }
            
            return .green
        }
        set {
            color = newValue.toHex() ?? "000000"
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
    
    func percentAsString(delimiter: String, symbol: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = delimiter
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let formatted = formatter.string(from: percentDecimalFraction as NSDecimalNumber) ?? "0"
        
        return formatted + " " + symbol
    }
    
}
