//
//  ModulesBundle.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 29.03.24.
//

import Foundation
import Swinject

extension DependencyResolver {
    
    func budgetWizzardViewModel(budget: BudgetEntity? = nil) throws -> BudgetWizardViewModel {
        if let budgetService = resolver.resolve(BudgetService.self), let dataService = resolver.resolve(DataService.self) {
            if let budgetEntity = budget {
                return BudgetWizardViewModel(budgetEntity, budgetService: budgetService, dataService: dataService)
            }
            
            return BudgetWizardViewModel(budgetService.newBudgetEntity(), budgetService: budgetService, dataService: dataService)
        }
        
        throw DependencyResolverError.ResolveError(msg: "Failed to resolve dependencies", reason: nil)
    }
    
    func budgetViewModel(_ budget: BudgetEntity) throws -> BudgetViewModel {
        if let budgetService = resolver.resolve(BudgetService.self), let budgetId = budget.id {
            return BudgetViewModel(
                budget: budget,
                period: try budgetService.getOrCreateLastPeriod(budgetId),
                categories: try budgetService.getCategoriesOfBudget(budgetId),
                budgetService: budgetService
            )
        }
        
        throw DependencyResolverError.ResolveError(msg: "Failed to resolve dependencies", reason: nil)
    }
    
    func transactionSheetViewModel(budget: BudgetEntity) throws -> TransactionSheetViewModel {
        if let budgetService = resolver.resolve(BudgetService.self) {
            return TransactionSheetViewModel(
                budget: budget,
                budgetService: budgetService
            )
        }
        
        throw DependencyResolverError.ResolveError(msg: "Failed to resolve dependencies", reason: nil)
    }
    
    func budgetListViewModel() throws -> BudgetListViewModel {
        if let budgetService = resolver.resolve(BudgetService.self) {
            return BudgetListViewModel(
                budgetService: budgetService
            )
        }
        
        throw DependencyResolverError.ResolveError(msg: "Failed to resolve dependencies", reason: nil)
    }
    
}
