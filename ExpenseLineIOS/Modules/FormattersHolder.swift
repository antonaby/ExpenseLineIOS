//
//  FormattersHolder.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 20.06.24.
//

import Foundation


class FormattersHolder: ObservableObject {
    
    private var currencyFormatter: NumberFormatter
    private var percentFormatter: NumberFormatter
    private var monthFormatter: DateFormatter
    private var dateFormatter: DateFormatter
    private var hourFormatter: DateFormatter

    init(locale: Locale) {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = locale
        currencyFormatter.minimumFractionDigits = 0
        currencyFormatter.maximumFractionDigits = 2
        self.currencyFormatter = currencyFormatter
        
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = locale
        percentFormatter.minimumFractionDigits = 0
        percentFormatter.maximumFractionDigits = 0
        self.percentFormatter = percentFormatter
        
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale.current
        monthFormatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        self.monthFormatter = monthFormatter
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.setLocalizedDateFormatFromTemplate("MM-dd-yyyy HH:mm")
        self.dateFormatter = dateFormatter
        
        let hourFormatter = DateFormatter()
        hourFormatter.locale = Locale.current
        hourFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        self.hourFormatter = hourFormatter
    }
    
    func formatAmount(_ amount: Decimal) -> String {
        if let fomatted = currencyFormatter.string(from: amount as NSDecimalNumber) {
            return fomatted
        }
        
        print("Error, amount: \(amount) can't be formatted") // TODO: send error event
        return "?"
    }
    
    func formatPercent(_ percent: Decimal) -> String {
        if let fomatted = percentFormatter.string(from: percent as NSDecimalNumber) {
            return fomatted
        }
        
        print("Error, amount: \(percent) can't be formatted") // TODO: send error event
        return "?"
    }
    
    func formatMonth(_ date: Date?) -> String {
        if let currentDate = date {
            return monthFormatter.string(from: currentDate)
        }
        
        return "?"
    }
    
    func formatDate(_ date: Date?) -> String {
        if let currentDate = date {
            return dateFormatter.string(from: currentDate)
        }
        
        return "?"
    }
    
    func formatHour(_ date: Date?) -> String {
        if let currentDate = date {
            return hourFormatter.string(from: currentDate)
        }
        
        return "?"
    }
    
}
