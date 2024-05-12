//
//  BaseViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import Foundation


class BudgetListViewModel: ObservableObject {
    
    @Published var selectedBudget: BudgetEntity?
    @Published var budgets: [BudgetEntity]
    
    private let budgetService: BudgetService
    private let dataService: DataService
    
    init(budgetService: BudgetService, dataService: DataService) {
        self.budgetService = budgetService
        self.dataService = dataService
        self.budgets = []
    }
    
    func loadBudgets() {
        do {
            budgets = try budgetService.getAllBudgets()
        } catch {
            // TODO: show error message
            print("Something went wrong: \(error)")
        }
    }
    
    func budgetWizzardViewModel() -> BudgetWizardViewModel {
        if let budget = selectedBudget {
            return BudgetWizardViewModel(budget, budgetService: budgetService, dataService: dataService)
        }
        
        return BudgetWizardViewModel(budgetService.newBudgetEntity(), budgetService: budgetService, dataService: dataService)
    }
    
    
}
