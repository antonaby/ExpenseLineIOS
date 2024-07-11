//
//  AnalyticsService.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.07.24.
//

import Foundation
import FirebaseAnalytics
import FirebaseAnalyticsSwift


class AnalyticsService: ObservableObject {
    
    public static let BUDGET_OPEN = "budget_open"
    public static let BUDGET_PERIOD_OPEN = "budget_period_open"
    public static let BUDGET_EDITED = "budget_edited"
    public static let BUDGET_NEW_OPEN = "budget_new_open"
    public static let BUDGET_NEW_CREATED = "budget_new_created"
    public static let APP_OPEN = "app_open"
    public static let PAYWALL_OPEN = "paywall_open"
    public static let PAYWALL_CLOSED = "paywall_closed"
    public static let NOTIFICATION_CREATED = "notification_created"
    public static let NOTIFICATION_EDITED = "notification_edited"
    public static let CATEGORY_CREATED = "category_created"
    public static let CATEGORY_EDITED = "category_edited"
    public static let HELP_OPEN = "help_open"
    public static let SETTGINS_COLOR_SCHEME = "settings_color_scheme"
    public static let DAILY_REMINDER_ENABLED = "daily_reminder_enabled"
    public static let DAILY_REMINDER_DISABLED = "daily_reminder_disabled"
    public static let TRANSACTION_CREATED = "transaction_created"
    public static let TRANSACTION_EDITED = "transaction_edited"
    
    private let settingService: SettingsService
    
    init(settingService: SettingsService) {
        self.settingService = settingService
    }
    
    func logEvent(name: String, params: [String:Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
    
    func updateUserId() {
        Analytics.setUserID(settingService.getUserId())
        logEvent(name: AnalyticsService.APP_OPEN)
    }
    
}
