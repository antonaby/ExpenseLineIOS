//
//  HelpPage.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 23.06.24.
//

import Foundation

enum HelpPage: Int, Identifiable {
    
    case mainWizard = 0
    case incomeWizard = 1
    case fixedOutcomeWizard = 2
    case flexibleOutcomeWizard = 3
    
    case mainPage = 4
    
    var id: Self { self }
    
}
