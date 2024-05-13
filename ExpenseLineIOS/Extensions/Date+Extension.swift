//
//  Date+Extension.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.05.24.
//

import Foundation

extension Date {
    
    func firstDayOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }
    
    func dateRangeFromBegingOfMonth() -> ClosedRange<Date> {
        return firstDayOfMonth() ... self
    }
    
    func lastDayOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month += 1
        components.day = 1
        components.day -= 1
        components.hour = 23
        components.minute = 59
        components.second = 59
        components.nanosecond = 999000000
        
        return Calendar.current.date(from: components as DateComponents)!
    }
    
}
