//
//  Budget.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 30.03.24.
//

import Foundation


enum PlanType: Int, CaseIterable, Identifiable {
    
    case mountly = 1
    case weekly = 2
    
    var id: Self { self }
    
}

struct Budget: Identifiable, Hashable {
    
    let id: UUID
    let name: String
    let currency: String
    let type: PlanType
    
}

extension BudgetEntity {
    
    var planTypeValue: PlanType {
        get {
            PlanType(rawValue: Int(self.planType))!
        }
        set {
            self.planType = Int64(newValue.rawValue)
        }
    }
    
}

struct BudgetPlan: Identifiable, Hashable {
    
    let id: UUID
    let startsAt: Date
    let endsAt: Date
    let createdAt: Date
    let plannedExpenses: Double
    let planType: PlanType
    
}

extension BudgetPlanEntity {
    
    var planTypeValue: PlanType {
        get {
            PlanType(rawValue: Int(self.planType))!
        }
        set {
            self.planType = Int64(newValue.rawValue)
        }
    }
    
}


