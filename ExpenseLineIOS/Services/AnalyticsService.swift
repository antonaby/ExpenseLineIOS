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
    
    func logEvent(name: String, params: [String:Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
    
}
