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
    case biweekly = 3
    
    var id: Self { self }
    
}

extension BudgetEntity {
    
    var planTypeValue: PlanType {
        get {
            PlanType(rawValue: Int(self.planType)) ?? .mountly
        }
        set {
            self.planType = Int64(newValue.rawValue)
        }
    }
    
    var currencyValue: String {
        get {
            currency ?? Locale.current.identifier
        }
    }
    
    func totalAmountForCategoryType(_ type: CategoryType) -> Decimal {
        let incomeCategories = categoriesForType([type])
        return incomeCategories.reduce(0) { $0 + $1.amountDecimal }
    }
    
    func totalPercentForCategoryType(_ type: CategoryType) -> Decimal {
        let incomeCategories = categoriesForType([type])
        return incomeCategories.reduce(0) { $0 + ($1.percentDecimal) }
    }
    
    func categoriesForType(_ types: [CategoryType], skipUnnamed: Bool = false) -> [PlanCategoryEntity] {
        let categories = categories?.allObjects as? [PlanCategoryEntity] ?? []
        if skipUnnamed {
            return categories
                .filter { !$0.nameValue.isEmpty && types.contains($0.typeValue) }
                .sorted(by: { $0.nameValue < $1.nameValue })
        }
        
        return categories
            .filter { types.contains($0.typeValue) }
            .sorted(by: { $0.nameValue < $1.nameValue })
    }
    
}
