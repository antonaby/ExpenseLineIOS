//
//  ModulesBundle.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 29.03.24.
//

import Foundation
import Swinject


class ModulesBundle: Assembly {
    
    func assemble(container: Swinject.Container) {
        container.register(AppState.self) { resolver in
            AppState()
        }.inObjectScope(.container)
        
        container.register(BudgetViewModel.self) { resolver in
            BudgetViewModel(es: resolver.resolve(ExpensesService.self)!)
        }.inObjectScope(.graph)
        container.register(CreateExpenseSheetViewModel.self) { resolver in
            CreateExpenseSheetViewModel(es: resolver.resolve(ExpensesService.self)!)
        }.inObjectScope(.graph)
        container.register(CreateSpaceSheetViewModel.self) { resolver in
            CreateSpaceSheetViewModel(es: resolver.resolve(ExpensesService.self)!)
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
    
    func budgetViewModel() -> BudgetViewModel {
        resolver.resolve(BudgetViewModel.self)!
    }
    
    func createExpenseSheetViewModel() -> CreateExpenseSheetViewModel {
        resolver.resolve(CreateExpenseSheetViewModel.self)!
    }
    
    func createSpaceSheetViewModel() -> CreateSpaceSheetViewModel {
        resolver.resolve(CreateSpaceSheetViewModel.self)!
    }
    
    func spaceViewModel(_ entity: SpaceEntity) -> SpaceViewModel {
        resolver.resolve(SpaceViewModel.self, argument: entity)!
    }
    
    func budgetListViewModel() -> BudgetListViewModel {
        resolver.resolve(BudgetListViewModel.self)!
    }
    
    func createBudgetSheetViewModel() -> CreateBudgetSheetViewModel {
        resolver.resolve(CreateBudgetSheetViewModel.self)!
    }
    
}
