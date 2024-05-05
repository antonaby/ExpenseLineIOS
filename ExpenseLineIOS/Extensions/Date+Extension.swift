//
//  Date+Extension.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.05.24.
//

import Foundation

extension Date {
    
    func firstDayOfMonth() -> Date {
        let periodComponents = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: periodComponents)!
    }
    
    func dateRangeFromBegingOfMonth() -> ClosedRange<Date> {
        return firstDayOfMonth() ... self
    }
    
}
