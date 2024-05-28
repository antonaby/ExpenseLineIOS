//
//  DataService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.04.24.
//

import Foundation

class DataService: ObservableObject {
    
    private let categories: [CategoryTemplateType]
    private let countryCurrencies: [CountryCurrency]
    
    init() {
        let decoder = JSONDecoder()
        
        var loadedCategories: [CategoryTemplateType]? = nil
        if let filepath = Bundle.main.url(forResource: "categories", withExtension: "json") {
            do {
                if let data = try? Data(contentsOf: filepath) {
                    loadedCategories = try decoder.decode([CategoryTemplateType].self, from: data)
                }
            } catch {
                print("Something went wrong \(error)")
            }
        }
        
        if let parsedCategories = loadedCategories {
            self.categories = parsedCategories
        } else {
            self.categories = [
                CategoryTemplateType(id: "Income", type: .income, templates: [
                    CategoryTemplate(id: "Income", iconName: "018-income")
                ]),
                CategoryTemplateType(id: "Outcome Fixed", type: .outcomeFixed, templates: [
                    CategoryTemplate(id: "Fixed", iconName: "024-mortgage")
                ]),
                CategoryTemplateType(id: "Outcome Flexible", type: .outcomePercent, templates: [
                    CategoryTemplate(id: "Flexible", iconName: "005-coffee")
                ])
            ]
        }
        
        var loadedCountryCurrencies: [CountryCurrency]? = nil
        
        if let filepath = Bundle.main.url(forResource: "countries", withExtension: "json") {
            do {
                if let data = try? Data(contentsOf: filepath) {
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
