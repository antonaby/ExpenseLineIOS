//
//  DataService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.04.24.
//

import Foundation
import SwiftUI

class DataService: ObservableObject {
    
    private let budgetService: BudgetService
    private let categories: [CategoryTemplateType]
    private let countryCurrencies: [CountryCurrency]
    
    init(budgetService: BudgetService) {
        self.budgetService = budgetService
        
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
                    CategoryTemplate(id: "ctg.income.unknown", name: "Salary", iconName: "question")
                ]),
                CategoryTemplateType(id: "outcome.fixed", type: .outcomeFixed, templates: [
                    CategoryTemplate(id: "ctg.outcome.fixed.unknown", name: "Payments", iconName: "question")
                ]),
                CategoryTemplateType(id: "outcome.flexible", type: .outcomePercent, templates: [
                    CategoryTemplate(id: "ctg.outcome.flexible.unknown", name: "Delivery & Take Away", iconName: "question")
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
    
    func getDefaultCategories(budget: BudgetEntity) -> [PlanCategoryEntity] {
        return [
            createCategoryFromTemplate(templateId: "ctg.income.salary", amount: 0, type: .income, color: "013220", order: 0, budget: budget),
            createCategoryFromTemplate(templateId: "ctg.income.investment", amount: 0, type: .income, color: "00008B", order: 1, budget: budget),
            
            createCategoryFromTemplate(templateId: "ctg.outcome.fixed.house", amount: 0, type: .outcomeFixed, color: "FF5733", order: 0, budget: budget),
            createCategoryFromTemplate(templateId: "ctg.outcome.fixed.mobile", amount: 0, type: .outcomeFixed, color: "808080", order: 1, budget: budget),
            createCategoryFromTemplate(templateId: "ctg.outcome.fixed.internet", amount: 0, type: .outcomeFixed, color: "088F8F", order: 2, budget: budget),
            createCategoryFromTemplate(templateId: "ctg.outcome.fixed.subscription", amount: 0, type: .outcomeFixed, color: "280137", order: 3, budget: budget),
            
            createCategoryFromTemplate(templateId: "ctg.outcome.flexible.groceries", amount: 0.05, type: .outcomePercent, color: "b5651d", order: 0, budget: budget),
            createCategoryFromTemplate(templateId: "ctg.outcome.flexible.food-delivery", amount: 0.1, type: .outcomePercent, color: "8B8000", order: 1, budget: budget),
            createCategoryFromTemplate(templateId: "ctg.outcome.flexible.coffee", amount: 0.01, type: .outcomePercent, color: "964B00", order: 2, budget: budget),
            createCategoryFromTemplate(templateId: "ctg.outcome.flexible.shopping", amount: 0.15, type: .outcomePercent, color: "1F51FF", order: 3, budget: budget),
            createCategoryFromTemplate(templateId: "ctg.outcome.flexible.pet", amount: 0.05, type: .outcomePercent, color: "FF5F1F", order: 4, budget: budget),
            createCategoryFromTemplate(templateId: "ctg.outcome.flexible.other", amount: 0.15, type: .outcomePercent, color: "000000", order: 5, budget: budget)
        ]
    }
    
    private func createCategoryFromTemplate(
        templateId: String,
        amount: Decimal,
        type: CategoryType,
        color: String,
        order: Int32,
        budget: BudgetEntity
    ) -> PlanCategoryEntity {
        let template = getTemplateById(templateId)!
        
        let category = budgetService.newCategoryEntity(budget)
        category.typeValue = type
        category.amountDecimal = type != .outcomePercent ? amount : 0
        category.percentDecimal = type == .outcomePercent ? amount : 0
        category.name = template.name
        category.iconName = template.iconName
        category.templateId = template.id
        category.colorValue = Color.init(hex: color) ?? .black
        category.order = order
        
        return category
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
