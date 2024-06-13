//
//  NotificationView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 08.06.24.
//

import SwiftUI


struct NotificationsView: View {
    
    @EnvironmentObject var notificationService: NotificationService
    
    @StateObject var vm: NotificationsViewModel
    @State var showEditNotificationSheet: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack {
                    ForEach($vm.notifications) { $notification in
                        FlexibleCardView {
                            Toggle(isOn: $notification.enabled) {
                                Text(notification.nameValue)
                            }
                            .tint(Color("FrDefault"))
                        }
                    }
                }
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity)
            }
            AddExpenseButton {
                showEditNotificationSheet.toggle()
            }
            .offset(x: -20, y: -20)
        }
        .background(Color("BgDefault"))
        .onAppear {
            vm.loadNotifications()
        }
        .sheet(isPresented: $showEditNotificationSheet, onDismiss: onNotificationUpdated) {
            EditNotificationSheetView(
                vm: EditNotificationSheetViewModel(notification: vm.newNotification(),
                                                   notificationService: notificationService))
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
    }
    
    func onNotificationUpdated() {
        vm.loadNotifications()
    }
    
}


#Preview("Notifications") {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    
    let notification1 = bundle.notificationService.newNotificationEntity(budget)
    notification1.name = "Preview 1"
    notification1.enabled = true
    
    let notification2 = bundle.notificationService.newNotificationEntity(budget)
    notification2.name = "Preview 2"
    
    let vm = NotificationsViewModel(budget: budget, notificationService: bundle.notificationService)
    
    return NotificationsView(vm: vm)
        .serviceBundle(bundle)
}

#Preview("No notifications") {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    
    let vm = NotificationsViewModel(budget: budget, notificationService: bundle.notificationService)
    
    return NotificationsView(vm: vm)
        .serviceBundle(bundle)
}
