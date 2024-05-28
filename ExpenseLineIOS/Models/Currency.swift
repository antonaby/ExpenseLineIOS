//
//  Currency.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.05.24.
//

import Foundation

struct CurrencyLocale: Codable {
    var locale: String
    var currency: String
    var symbol: String
}

struct CountryCurrency: Codable {
    var code: String
    var name: String
    var defaultLocale: String
    var locales: [CurrencyLocale]
}

struct CurrencySymbol: Identifiable {
    
    let id: String
    let name: String
    
    var locale: Locale {
        Locale(identifier: id)
    }
    
    var code: String {
        locale.currency?.identifier ?? "?"
    }
    
    var symbol: String {
        locale.currency?.identifier.currencySymbol ?? "?"
    }
    
}
