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
                    NotificationTypeCardView()
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
    
    @ViewBuilder
    func NotificationTypeCardView() -> some View {
        FlexibleCardView {
            HStack {
                ForEach(NotificationType.allCases) { type in
                    Button {
                        vm.type = type
                    } label: {
                        VStack {
                            Image(systemName: getTypeImage(type))
                                .font(.title3)
                            Text(getTypeName(type))
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(vm.type == type ? Color("FrDefault") : .black)
                    }
                }
            }
        }
    }
    
    private func getTypeImage(_ type: NotificationType) -> String {
        switch type {
        case .exact:
            "checkmark"
        case .everyday:
            "bell"
        case .weekdays:
            "rectangle.and.pencil.and.ellipsis"
        case .days:
            "calendar"
        }
    }
    
    private func getTypeName(_ type: NotificationType) -> String {
        switch type {
        case .exact:
            "Exact"
        case .everyday:
            "Everyday"
        case .weekdays:
            "Weekdays"
        case .days:
            "Calendar"
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
