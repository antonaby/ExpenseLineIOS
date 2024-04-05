//
//  BudgetWizardViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.04.24.
//

import Foundation


class BudgetWizardViewModel: ObservableObject {
    
    @Published var currentStageIndex: Int
    @Published var name: String
    @Published var currency: String
    
    init() {
        self.currentStageIndex = 0
        self.name = ""
        self.currency = "USD"
    }
    
    func previousPage() {
        if currentStageIndex - 1 >= 0 {
            currentStageIndex -= 1
        }
    }
 
    func nextPage() {
        if currentStageIndex + 1 <= 2 {
            currentStageIndex += 1
        }
    }
    
    func getCurrencies() -> [String] {
        ["USD", "EUR", "AMD", "RUB"]
    }
    
    func createBudget() {
        
    }
    
}

