//
//  NotificationSheetView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 10.06.24.
//

import SwiftUI

struct EditNotificationSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var vm: EditNotificationSheetViewModel
    
    var body: some View {
        VStack {
            HStack {
                ToolButton(icon: "x.circle", color: Color("Accent1")) {
                    vm.rollback()
                    dismiss()
                }
                Spacer()
                Text("Reminder")
                    .font(.headline)
                Spacer()
                ToolButton(color: Color("FrDefault")) {
                    vm.save()
                    dismiss()
                }
                .disabled(!vm.isValid)
            }
            .padding([.horizontal, .top], 10)
            .padding([.bottom], 5)
            .font(.title2)
            ScrollView {
                VStack {
                    FlexibleCardView {
                        HStack {
                            Image(systemName: "bell")
                                .frame(width: 30)
                            TextField("Name", text: $vm.name)
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 15)
            }
            .background(Color("BgDefault"))
        }
        .interactiveDismissDisabled(true)
        .onDisappear {
            vm.cancelAll()
        }
    }
    
}

#Preview("New") {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    let notification = bundle.notificationService.newNotificationEntity(budget)
    
    let vm = EditNotificationSheetViewModel(
        notification: notification,
        notificationService: bundle.notificationService
    )
    
    return EditNotificationSheetView(vm: vm)
        .serviceBundle(bundle)
}
