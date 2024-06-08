//
//  NotificationView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 08.06.24.
//

import SwiftUI


struct NotificationsView: View {
    
    @StateObject var vm: NotificationsViewModel
    
    var body: some View {
        Text("Notification")
    }
    
}


#Preview {
    
    
    return NotificationsView(vm: NotificationsViewModel())
}
