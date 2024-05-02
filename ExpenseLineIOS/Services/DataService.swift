//
//  DataService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.04.24.
//

import Foundation


class DataService {
    
    private let categories: [CategoryTemplateType]
    
    init() {
        self.categories = [
            CategoryTemplateType(id: UUID(), name: "Income", type: .income, templates: [
                CategoryTemplate(id: UUID(), name: "Salary", iconName: "case"),
                CategoryTemplate(id: UUID(), name: "Savings", iconName: "banknote"),
            ]),
            CategoryTemplateType(id: UUID(), name: "Outcome", type: .outcomeFixed, templates: [
                CategoryTemplate(id: UUID(), name: "Rent", iconName: "house"),
                CategoryTemplate(id: UUID(), name: "Internet", iconName: "globe"),
            ]),
            CategoryTemplateType(id: UUID(), name: "Daily", type: .outcomePercent, templates: [
                CategoryTemplate(id: UUID(), name: "Groceries", iconName: "takeoutbag.and.cup.and.straw"),
                CategoryTemplate(id: UUID(), name: "Coffee", iconName: "cup.and.saucer"),
                CategoryTemplate(id: UUID(), name: "Transport", iconName: "car"),
                CategoryTemplate(id: UUID(), name: "Dinner", iconName: "wineglass"),
                CategoryTemplate(id: UUID(), name: "Club", iconName: "party.popper"),
                CategoryTemplate(id: UUID(), name: "Wine", iconName: "wineglass.fill"),
            ]),
        ]
    }
    
    func getCategoryTemplates(of type: CategoryType) -> [CategoryTemplateType] {
        return categories.filter { $0.type == type }
    }
    
    func getCategoryTemplates(not type: CategoryType) -> [CategoryTemplateType] {
        return categories.filter { $0.type != type }
    }
    
}
