//
//  HelpPage.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 23.06.24.
//

import Foundation

enum HelpPage: String, Identifiable {
    
    case mainWizard = "help.wizard.main.fisrt"
    case incomeWizard = "help.wizard.income.fisrt"
    case fixedOutcomeWizard = "help.wizard.outcome.fixed.fisrt"
    case flexibleOutcomeWizard = "help.wizard.outcome.flexible.fisrt"
    
    case mainPage = "help.budget.main.first"
    
    var id: Self { self }
    
}
