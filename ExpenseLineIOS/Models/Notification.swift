//
//  Notification.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 08.06.24.
//

import Foundation


struct NotificationWeekDay: Identifiable {
    
    var id: Int
    var shortName: String
    
}

enum NotificationType: Int, CaseIterable, Identifiable, Codable {
    
    case nonotification = 0
    case exact = 1
    case daily = 2
    case weekly = 3
    
    var id: Self { self }
    
}

extension NotificationEntity {
    
    var nameValue: String {
        get {
            name ?? ""
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
    
}
