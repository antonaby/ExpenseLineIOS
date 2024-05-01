//
//  Category.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.05.24.
//

import Foundation

enum CategoryType: Int, CaseIterable, Identifiable {
    
    case income = 1
    case outcomeFixed = 2
    case outcomePercent = 3
    
    var id: Self { self }
    
}

struct CategoryTemplate: Identifiable {
    
    var id: UUID
    var name: String
    var iconName: String
    
}

struct CategoryTemplateType: Identifiable {
    
    var id: UUID
    var name: String
    var type: CategoryType
    var templates: [CategoryTemplate]
    
}
