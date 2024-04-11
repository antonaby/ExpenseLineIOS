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
    
    @Published var budget: BudgetEntity?
    
    // TODO: move resolver outside
    let resolver: DependencyResolver
    
    private let userDefaults: UserDefaults
    
    init() {
        self.userDefaults = UserDefaults(suiteName: "Budget")!
        self.resolver = DependencyResolver(assemblies: DatabaseManagerBundle(), ServiceBundle(), ModulesBundle())
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
    
    private func getBudget() -> BudgetEntity? {
        if let data = userDefaults.data(forKey: "budgetId") {
            do {
                let decoder = JSONDecoder()
                let budgetId = try decoder.decode(BudgetId.self, from: data)
                if let id = budgetId.id {
                    let es = resolver.expensesService()
                    return try es.getBudgetById(id)
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
