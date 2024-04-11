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
        
        // TODO: review
        
        container.register(CreateExpenseSheetViewModel.self) { resolver, entity in
            CreateExpenseSheetViewModel(budget: entity, es: resolver.resolve(ExpensesService.self)!)
        }.inObjectScope(.graph)
        container.register(CreateSpaceSheetViewModel.self) { resolver, entity in
            CreateSpaceSheetViewModel(budget: entity, es: resolver.resolve(ExpensesService.self)!)
        }.inObjectScope(.graph)
        container.register(SpaceViewModel.self) { resolver, entity in
            SpaceViewModel(entity, es: resolver.resolve(ExpensesService.self)!)
        }.inObjectScope(.graph)
        container.register(BudgetListViewModel.self) { resolver in
            BudgetListViewModel(es: resolver.resolve(ExpensesService.self)!)
        }.inObjectScope(.graph)
        container.register(CreateBudgetSheetViewModel.self) { resolver in
            CreateBudgetSheetViewModel(es: resolver.resolve(ExpensesService.self)!)
        }.inObjectScope(.graph)
    }
    
}

extension DependencyResolver {
    
    func appState() -> AppState {
        resolver.resolve(AppState.self)!
    }
    
    func budgetWizzardViewModel() -> BudgetWizardViewModel {
        BudgetWizardViewModel(budgetService: resolver.resolve(BudgetService.self)!)
    }
    
    func budgetViewModel(_ budget: BudgetEntity) throws -> BudgetViewModel {
        if let budgetService = resolver.resolve(BudgetService.self), let budgetId = budget.id {
            return BudgetViewModel(
                budget: budget,
                period: try budgetService.getOrCreateLastPeriod(budgetId),
                budgetService: budgetService
            )
        }
        
        throw ModuleBundleError.ResolveError(msg: "Failed to resolve dependencies", reason: nil)
    }
    
    // TODO: review
    
    
    func createExpenseSheetViewModel(_ plan: BudgetPlanEntity) -> CreateExpenseSheetViewModel {
        resolver.resolve(CreateExpenseSheetViewModel.self, argument: plan)!
    }
    
    func createSpaceSheetViewModel(_ budget: BudgetEntity) -> CreateSpaceSheetViewModel {
        resolver.resolve(CreateSpaceSheetViewModel.self, argument: budget)!
    }
    
    func spaceViewModel(_ space: SpaceEntity) -> SpaceViewModel {
        resolver.resolve(SpaceViewModel.self, argument: space)!
    }
    
    func budgetListViewModel() -> BudgetListViewModel {
        resolver.resolve(BudgetListViewModel.self)!
    }
    
    func createBudgetSheetViewModel() -> CreateBudgetSheetViewModel {
        resolver.resolve(CreateBudgetSheetViewModel.self)!
    }
    
}
