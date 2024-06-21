//
//  BaseViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import Foundation


class BudgetListViewModel: ObservableObject {
    
    @Published var budgets: [BudgetEntity]
    
    private let budgetService: BudgetService
    private let dataService: DataService
    private let notificationService: NotificationService
    
    init(budgetService: BudgetService, dataService: DataService, notificationService: NotificationService) {
        self.budgetService = budgetService
        self.dataService = dataService
        self.notificationService = notificationService
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
    
    func budgetWizzardViewModel(_ budget: BudgetEntity) -> BudgetWizardViewModel {
        return BudgetWizardViewModel(budget,
                                     budgetService: budgetService,
                                     dataService: dataService,
                                     notificationService: notificationService)
    }
    
    func newBudgetWizzardViewModel() -> BudgetWizardViewModel {
        let budget = budgetService.newBudgetEntity()
        budget.dailyRemainderAt = Date().currentDateAt(at: 20)
        for category in dataService.getDefaultCategories(budget: budget) {
            budget.addToCategories(category)
        }
        
        return BudgetWizardViewModel(budget,
                                     budgetService: budgetService,
                                     dataService: dataService,
                                     notificationService: notificationService)
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
