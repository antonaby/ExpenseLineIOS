//
//  Locale+Extension.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 30.04.24.
//

import Foundation

extension Locale {
    
    func isCurrencySymbolTrailing() -> Bool {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        if let string = formatter.string(for: NSNumber(floatLiteral: 1.5)), let firstSymbol = currencySymbol?.first {
            if let index = string.firstIndex(of: firstSymbol) {
                let distance = string.distance(from: string.startIndex, to: index)
                return distance > 0
            }
        }
        
        return false
    }
    
    func currencySymbolOrDefault(_ defaultValue: String) -> String {
        currencySymbol ?? defaultValue
    }
    
    func decimalSepapatorOrDefault(_ defaultValue: String) -> String {
        decimalSeparator ?? defaultValue
    }
    
}
