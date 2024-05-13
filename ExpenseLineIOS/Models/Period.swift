//
//  Period.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 13.05.24.
//

import Foundation

extension PeriodEntity {
    
    var currentMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        
        return dateFormatter.string(from: startsAt ?? Date())
    }
    
}
