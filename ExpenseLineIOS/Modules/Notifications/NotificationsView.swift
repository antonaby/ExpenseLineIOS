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
    let bundle = ServiceBundle.preview
    
    return NotificationsView(vm: NotificationsViewModel(notificationService: bundle.notificationService))
}
