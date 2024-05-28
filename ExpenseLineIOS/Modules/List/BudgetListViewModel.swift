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
        
        let budget = budgetService.newBudgetEntity()
        let categoryTemplates = dataService.getDefaultCategories()
        
        for type in categoryTemplates {
            for template in type.templates {
                let category = budgetService.newCategoryEntity(budget)
                category.typeValue = type.type
                category.amountDecimal = 0
                category.percentDecimal = 0
                category.name = template.name
                category.iconName = template.iconName
                category.templateId = template.id
                category.colorValue = .black
                
                budget.addToCategories(category)
            }
        }
        
        return BudgetWizardViewModel(budget, budgetService: budgetService, dataService: dataService)
    }
    
    func deleteBudget(_ budget: BudgetEntity) {
        do {
            budgetService.deleteBudget(budget)
            try budgetService.save()
            budgets = try budgetService.getAllBudgets()
        } catch {
            // TODO: show error message
            print("Something went wrong: \(error)")
        }
    }
    
}
