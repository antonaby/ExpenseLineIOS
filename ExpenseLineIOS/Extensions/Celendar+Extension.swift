//
//  Celendar+Extension.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 20.05.24.
//

import Foundation

extension Calendar {
    
    func numberOfDaysBetween(from: Date, to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day! + 1
    }
    
}
