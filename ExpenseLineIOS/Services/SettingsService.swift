//
//  SettingsService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.05.24.
//

import Foundation

struct BoolUserPreference: Identifiable {
    var id: String
    var name: String
    var value: Bool
}

class SettingsService: ObservableObject {
    
    static let BUDGET_ID_KEY = "budgetId"
    static let APP_FIRST_LAUNCH_DONE = "app.first.launch.done"
    static let SHOW_HELP_BUTTON = "show.help.button"
    
    private let userSettings: UserDefaults
       
    init() {
        if let bundle = UserDefaults(suiteName: "Budget") {
            self.userSettings = bundle
        } else {
            self.userSettings = UserDefaults.standard
        }
    }
    
    func getBudgetId() -> UUID? {
        if let budgetIdStr = userSettings.string(forKey: "budgetId"),
           let budgetId = UUID(uuidString: budgetIdStr) {
            return budgetId
        }
        
        return nil
    }
    
    func setBudgetId(_ id: UUID?) {
        if let currentId = id {
            userSettings.setValue(currentId.uuidString, forKey: "budgetId")
        } else {
            userSettings.removeObject(forKey: "budgetId")
        }
    }
    
    func setBoolPreference(for key: String, value: Bool) {
        userSettings.setValue(value, forKey: key)
    }
    
    func getBoolPreference(for key: String) -> Bool {
        userSettings.bool(forKey: key)
    }
    
    func alwaysShowHelp() -> Bool {
        return false
    }
    
}
