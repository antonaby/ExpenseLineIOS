//
//  AppState.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import Foundation


struct BudgetId: Codable {
    
    var id: UUID?
    
}

class AppState: ObservableObject {
    
    @Published var showError: Bool?
    @Published var budget: BudgetEntity?

    private let budgetService: BudgetService
    private let userDefaults: UserDefaults
    
    init(budgetService: BudgetService) {
        self.userDefaults = UserDefaults(suiteName: "Budget")! // TODO: check nil
        self.budgetService = budgetService
    }
    
    func selectBudget(_ budget: BudgetEntity) {
        self.budget = budget
        saveBudgetId(budget.id)
    }
    
    func unselectBudget() {
        budget = nil
        saveBudgetId(nil)
    }
    
    func loadBudget() {
        budget = getBudget()
    }
    
    func budgetViewModel(_ budget: BudgetEntity) -> BudgetViewModel? {
        do {
            return BudgetViewModel(
                budget: budget,
                period: try budgetService.getOrCreateLastPeriod(budget),
                budgetService: budgetService
            )
        } catch {
            showError = true
        }
        
        return nil
    }

    private func getBudget() -> BudgetEntity? {
        if let data = userDefaults.data(forKey: "budgetId") {
            do {
                let decoder = JSONDecoder()
                let budgetId = try decoder.decode(BudgetId.self, from: data)
                if let id = budgetId.id {
                    return try budgetService.getBudgetById(id)
                }
            } catch {
                // TODO: show error
                print("Can't fetch budget info: \(error)")
            }
        }
        
        return nil
    }
    
    private func saveBudgetId(_ id: UUID?) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(BudgetId(id: id))
            userDefaults.set(data, forKey: "budgetId")
        } catch {
            // TODO: show error
            print("Can't save budget info: \(error)")
        }
    }
    
}
