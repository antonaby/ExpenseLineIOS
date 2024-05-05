//
//  DataService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.04.24.
//

import Foundation


class DataService {
    
    private let categories: [CategoryTemplateType]
    private let currencies: [CurrencyLocale]
    
    init() {
        self.categories = [
            CategoryTemplateType(id: UUID(), name: "Income", type: .income, templates: [
                CategoryTemplate(id: UUID(uuidString: "cb354891-2ade-4268-8419-58b50ce80b36")!, name: "Salary", iconName: "case"),
                CategoryTemplate(id: UUID(uuidString: "62eb641f-2347-43a4-a73a-94592660bbbf")!, name: "Savings", iconName: "banknote"),
            ]),
            CategoryTemplateType(id: UUID(), name: "Outcome", type: .outcomeFixed, templates: [
                CategoryTemplate(id: UUID(uuidString: "eb87fc74-d487-42d2-b6c3-2e734cd18502")!, name: "Rent", iconName: "house"),
                CategoryTemplate(id: UUID(uuidString: "fc5738ef-cb39-4b2b-85a9-ce54666820d9")!, name: "Internet", iconName: "globe"),
            ]),
            CategoryTemplateType(id: UUID(), name: "Daily", type: .outcomePercent, templates: [
                CategoryTemplate(id: UUID(uuidString: "4e794d37-e5fb-4574-b105-4ec0a2d46ce9")!, name: "Groceries", iconName: "takeoutbag.and.cup.and.straw"),
                CategoryTemplate(id: UUID(uuidString: "e23eec61-f589-43c5-893c-fb898d729127")!, name: "Coffee", iconName: "cup.and.saucer"),
                CategoryTemplate(id: UUID(uuidString: "493f5b08-285f-443a-89f0-c473638aae83")!, name: "Transport", iconName: "car"),
                CategoryTemplate(id: UUID(uuidString: "07227b9d-da14-4dc1-8fde-c49550d02031")!, name: "Dinner", iconName: "wineglass"),
                CategoryTemplate(id: UUID(uuidString: "1271b562-d4ed-4efb-a9f1-eef83ae479f9")!, name: "Club", iconName: "party.popper"),
                CategoryTemplate(id: UUID(uuidString: "49de8df4-564f-471b-bcc0-f77d7c500067")!, name: "Wine", iconName: "wineglass.fill"),
            ]),
        ]
        self.currencies = [
            CurrencyLocale(id: "en_US", name: "US Dollar"),
            CurrencyLocale(id: "en_GB", name: "Pound"),
            CurrencyLocale(id: "de_DE", name: "EUR"),
            CurrencyLocale(id: "ru_RU", name: "Rub"),
            CurrencyLocale(id: "hy_AM", name: "Drum"),
            CurrencyLocale(id: "ta_IN", name: "RUP")
        ]
    }
    
    func getCategoryTemplates(of type: CategoryType) -> [CategoryTemplateType] {
        return categories.filter { $0.type == type }
    }
    
    func getCategoryTemplates(not type: CategoryType) -> [CategoryTemplateType] {
        return categories.filter { $0.type != type }
    }
    
    func getTemplateById(_ id: UUID) -> CategoryTemplate? {
        categories.map { $0.templates }.joined().filter { $0.id == id }.first
    }
    
    func getCurrencies() -> [CurrencyLocale] {
        return currencies
    }
    
}
