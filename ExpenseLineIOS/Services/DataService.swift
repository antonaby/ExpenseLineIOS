//
//  DataService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.04.24.
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

class DataService: ObservableObject {
    
    private let categories: [CategoryTemplateType]
    private let countryCurrencies: [CountryCurrency]
    
    init() {
        self.categories = [
            CategoryTemplateType(id: "Income", type: .income, templates: [
                CategoryTemplate(id: "Salary", iconName: "018-income"),
                CategoryTemplate(id: "Investments", iconName: "020-investment"),
            ]),
            CategoryTemplateType(id: "Outcome", type: .outcomeFixed, templates: [
                CategoryTemplate(id: "Rent", iconName: "024-mortgage"),
                CategoryTemplate(id: "Payments", iconName: "007-electricity")
            ]),
            CategoryTemplateType(id: "Daily", type: .outcomePercent, templates: [
                CategoryTemplate(id: "Groceries", iconName: "015-groceries"),
                CategoryTemplate(id: "Coffee", iconName: "005-coffee"),
                CategoryTemplate(id: "Transport", iconName: "013-gas"),
                CategoryTemplate(id: "Dinner", iconName: "011-food"),
                CategoryTemplate(id: "Intertament", iconName: "025-movie"),
                CategoryTemplate(id: "Alcohol", iconName: "006-drink"),
            ]),
        ]
        
        var loadedCountryCurrencies: [CountryCurrency]? = nil
        
        if let filepath = Bundle.main.url(forResource: "countries", withExtension: "json") {
            do {
                if let data = try? Data(contentsOf: filepath) {
                    let decoder = JSONDecoder()
                    loadedCountryCurrencies = try decoder.decode([CountryCurrency].self, from: data)
                }
            } catch {
                print("Something went wrong \(error)")
            }
        }
        
        if let parsedCountryCurrencies = loadedCountryCurrencies {
            countryCurrencies = parsedCountryCurrencies
        } else {
            countryCurrencies = [
                CountryCurrency(code: "US", name: "United States", defaultLocale: "en_US", locales: [
                    CurrencyLocale(locale: "en_US", currency: "USD", symbol: "$")
                ])
            ]
        }
    }
    
    func getCategoryTemplates(of type: CategoryType) -> [CategoryTemplateType] {
        return categories.filter { $0.type == type }
    }
    
    func getCategoryTemplates(not type: CategoryType) -> [CategoryTemplateType] {
        return categories.filter { $0.type != type }
    }
    
    func getTemplateById(_ id: String) -> CategoryTemplate? {
        categories.map { $0.templates }.joined().filter { $0.id == id }.first
    }
    
    func getCurrencies() -> [CurrencySymbol] {
        countryCurrencies.map { CurrencySymbol(
            id: $0.defaultLocale,
            name: Locale.current.localizedString(forRegionCode: $0.code) ?? $0.name
        ) }
    }
    
    func getCurrensySymbolById(_ id: String) -> CurrencySymbol? {
        if let countryCurrency = countryCurrencies.first(where: {
            $0.locales.first(where: { $0.locale == id }) != nil
        }) {
            
            return CurrencySymbol(
                id: countryCurrency.defaultLocale,
                name: Locale.current.localizedString(forRegionCode: countryCurrency.code) ?? countryCurrency.name)
        }
        
        return nil
    }
    
    func getDefaultCurrencySymbol() -> CurrencySymbol {
        getCurrensySymbolById("en_US")!
    }
    
    func getCurrencySymbolOrDefault(_ id: String) -> CurrencySymbol {
        getCurrensySymbolById(id) ?? getDefaultCurrencySymbol()
    }
    
}
