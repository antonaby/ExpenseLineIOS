//
//  SettingsService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.05.24.
//

import Foundation
import SwiftUI

class SettingsService: ObservableObject {
    
    static let BUDGET_ID_KEY = "budgetId"
    static let APP_FIRST_LAUNCH_DONE = "app.first.launch.done"
    static let APP_COLOR_SCHEME = "app.color.scheme"
    static let SHOW_HELP_BUTTON = "show.help.button"
    static let DAILY_REMINDER_ENABLED = "reminder.daily.enabled"
    static let DAILY_REMINDER_TIME = "reminder.daily.time"
    
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
    
    func setDailyReminder(date: Date) {
        let time = getHourFormatter().string(from: date)
        userSettings.setValue(time, forKey: SettingsService.DAILY_REMINDER_TIME)
    }
    
    func getDailyReminder() -> Date {
        if let dailyReminderStr = userSettings.string(forKey: SettingsService.DAILY_REMINDER_TIME) {
            let date = getHourFormatter().date(from: dailyReminderStr)
            if date != nil {
                return date!
            }
        }
        
        return Date().currentDateAt(at: 20)
    }
    
    func getColorScheme() -> ColorScheme? {
        if let schemeStr = userSettings.string(forKey: SettingsService.APP_COLOR_SCHEME) {
            switch schemeStr {
            case "dark":
                return .dark
            default:
                return .light
            }
        }
        
        return nil
    }
    
    func setColorScheme(_ scheme: ColorScheme?) {
        if let scheme = scheme {
            switch scheme {
            case .dark:
                userSettings.setValue("dark", forKey: SettingsService.APP_COLOR_SCHEME)
            default:
                userSettings.setValue("light", forKey: SettingsService.APP_COLOR_SCHEME)
            }
        } else {
            userSettings.removeObject(forKey: SettingsService.APP_COLOR_SCHEME)
        }
    }
    
    func setBoolPreference(for key: String, value: Bool) {
        userSettings.setValue(value, forKey: key)
    }
    
    func getBoolPreference(for key: String) -> Bool {
        userSettings.bool(forKey: key)
    }
    
    func isFirstLaunch() -> Bool {
        !getBoolPreference(for: SettingsService.APP_FIRST_LAUNCH_DONE)
    }
    
    func alwaysShowHelp() -> Bool {
        false
    }
    
    private func getHourFormatter() -> DateFormatter {
        let hourFormatter = DateFormatter()
        hourFormatter.locale = Locale(identifier: "en_US")
        hourFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        
        return hourFormatter
    }
    
}
