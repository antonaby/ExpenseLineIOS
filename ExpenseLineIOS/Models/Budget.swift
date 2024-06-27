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
    
    var allCategories: [PlanCategoryEntity] {
        get {
            categories?.allObjects as? [PlanCategoryEntity] ?? []
        }
    }
    
    func categoriesForType(_ types: [CategoryType], skipUnnamed: Bool = false) -> [PlanCategoryEntity] {
        let allCategories = categories?.allObjects as? [PlanCategoryEntity] ?? []
        let categories = allCategories.filter {
            if $0.nameValue.isEmpty && skipUnnamed {
                return false
            }
            
            return types.contains($0.typeValue)
        }
        
        return categories
            .sorted(by: {
                if $0.order != $1.order {
                    return $0.order < $1.order
                }
                
                return $0.nameValue < $1.nameValue
            })
    }
    
}
