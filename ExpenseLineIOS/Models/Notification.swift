//
//  Notification.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 08.06.24.
//

import Foundation


enum NotificationType: Int, CaseIterable, Identifiable, Codable {
    
    case exact = 1
    case everyday = 2
    case weekdays = 3
    case days = 4
    
    var id: Self { self }
    
}

extension NotificationEntity {
    
    var nameValue: String {
        get {
            name ?? "?"
        }
    }
    
    var typeValue: NotificationType {
        get {
            NotificationType(rawValue: Int(self.type)) ?? .exact
        }
        set {
            self.type = Int32(newValue.rawValue)
        }
    }
    
    var weekDaysArr: [Int] {
        get {
            weekDays?.split(separator: ",").map { Int($0)! } ?? []
        }
        set {
            self.weekDays = newValue.map { String($0) }.joined(separator: ",")
        }
    }
    
    var daysArr: [Int] {
        get {
            days?.split(separator: ",").map { Int($0)! } ?? []
        }
        set {
            self.days = newValue.map { String($0) }.joined(separator: ",")
        }
    }
    
}
