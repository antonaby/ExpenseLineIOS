//
//  ModulesBundle.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 29.03.24.
//

import Foundation
import Swinject

enum ModuleBundleError: Error {
    case ResolveError(msg: String, reason: Error?)
}


class ModulesBundle: Assembly {
    
    func assemble(container: Swinject.Container) {
        container.register(AppState.self) { resolver in
            AppState()
        }.inObjectScope(.container)
    }
    
}

extension DependencyResolver {
    
    func appState() -> AppState {
        resolver.resolve(AppState.self)!
    }
    
    func budgetWizzardViewModel(budget: BudgetEntity? = nil) throws -> BudgetWizardViewModel {
        if let budgetService = resolver.resolve(BudgetService.self),
           let dataService = resolver.resolve(DataService.self) {
            if let budgetEntity = budget {
                return BudgetWizardViewModel(budget: budgetEntity, budgetService: budgetService, dataService: dataService)
            }
            
            let budgetEntity = BudgetEntity(context: databaseManager().viewContext)
            return BudgetWizardViewModel(budget: budgetEntity, budgetService: budgetService, dataService: dataService)
        }
        
        throw ModuleBundleError.ResolveError(msg: "Failed to resolve dependencies", reason: nil)
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
        
        throw ModuleBundleError.ResolveError(msg: "Failed to resolve dependencies", reason: nil)
    }
    
    func transactionSheetViewModel(budget: BudgetEntity) throws -> TransactionSheetViewModel {
        if let budgetService = resolver.resolve(BudgetService.self) {
            return TransactionSheetViewModel(
                budget: budget,
                budgetService: budgetService
            )
        }
        
        throw ModuleBundleError.ResolveError(msg: "Failed to resolve dependencies", reason: nil)
    }
    
    func budgetListViewModel() throws -> BudgetListViewModel {
        if let budgetService = resolver.resolve(BudgetService.self) {
            return BudgetListViewModel(
                budgetService: budgetService
            )
        }
        
        throw ModuleBundleError.ResolveError(msg: "Failed to resolve dependencies", reason: nil)
    }
    
}
