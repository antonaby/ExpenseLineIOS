//
//  Currency.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.05.24.
//

import Foundation

struct CurrencyLocale: Identifiable {
    
    let id: String
    let name: String
    
    var locale: Locale {
        Locale(identifier: id)
    }
    
    var symbol: String {
        locale.currency?.identifier.currencySymbol ?? "?"
    }
    
}
