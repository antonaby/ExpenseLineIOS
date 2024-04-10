//
//  Space.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation

enum PlanCategoryType: Int, CaseIterable, Identifiable {
    
    case income = 1
    case outcomeFixed = 2
    case outcomePercent = 3
    
    var id: Self { self }
    
}

struct PlanCategory: Identifiable, Hashable {
    
    let id: UUID
    var name: String
    var amount: Double
    var percent: Double
    var iconName: String
    var type: PlanCategoryType
    var createdAt: Date
    
}

extension PlanCategoryEntity {
    
    var typeValue: PlanCategoryType {
        get {
            PlanCategoryType(rawValue: Int(self.type))!
        }
        set {
            self.type = Int64(newValue.rawValue)
        }
    }
    
}



// TODO: remove if needed
struct Space: Identifiable, Hashable {
    
    let id: UUID
    let name: String
    let iconName: String
    
}
