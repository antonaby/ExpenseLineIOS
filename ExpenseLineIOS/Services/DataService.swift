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
                CategoryTemplateType(id: "income", type: .income, templates: [
                    CategoryTemplate(id: "ctg.income.unknown", name: "Income", iconName: "question")
                ]),
                CategoryTemplateType(id: "outcome.fixed", type: .outcomeFixed, templates: [
                    CategoryTemplate(id: "ctg.outcome.fixed.unknown", name: "Fixed", iconName: "question")
                ]),
                CategoryTemplateType(id: "outcome.flexible", type: .outcomePercent, templates: [
                    CategoryTemplate(id: "ctg.outcome.flexible.unknown", name: "Flexible", iconName: "question")
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
    
    func getDefaultCategories() -> [CategoryTemplateType] {
        return [
            CategoryTemplateType(id: "income", type: .income, templates: [
                getTemplateById("ctg.income.salary")!,
                getTemplateById("ctg.income.passive-income")!,
                getTemplateById("ctg.income.other-income")!
            ]),
            CategoryTemplateType(id: "outcome.fixed", type: .outcomeFixed, templates: [
                getTemplateById("ctg.outcome.fixed.house")!,
                getTemplateById("ctg.outcome.fixed.mobile")!,
                getTemplateById("ctg.outcome.fixed.internet")!,
                getTemplateById("ctg.outcome.fixed.subscription")!,
                getTemplateById("ctg.outcome.fixed.other")!
            ]),
            CategoryTemplateType(id: "outcome.flexible", type: .outcomePercent, templates: [
                getTemplateById("ctg.outcome.flexible.groceries")!,
                getTemplateById("ctg.outcome.flexible.pet")!,
                getTemplateById("ctg.outcome.flexible.food-delivery")!,
                getTemplateById("ctg.outcome.flexible.coffee")!,
                getTemplateById("ctg.outcome.flexible.buyings")!,
            ])
        ]
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
