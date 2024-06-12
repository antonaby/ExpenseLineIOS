//
//  NotificationSheetView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 10.06.24.
//

import SwiftUI

struct EditNotificationSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var notificationService: NotificationService
    
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
                            Image(systemName: "pencil")
                                .frame(width: 30)
                            TextField("Name", text: $vm.name)
                        }
                    }
                    NotificationTypeCardView()
                    switch vm.type {
                    case .exact:
                        ExactNotificationView()
                    case .daily:
                        DailyNotificationView()
                    case .weekly:
                        WeeklyNotificationView()
                    case .monthly:
                        MonthlyNotificationView()
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
    
    @ViewBuilder
    func NotificationTypeCardView() -> some View {
        FlexibleCardView {
            HStack {
                ForEach(NotificationType.allCases) { type in
                    Button {
                        withAnimation {
                            vm.type = type
                        }
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
    
    @ViewBuilder
    func ExactNotificationView() -> some View {
        FlexibleCardView {
            VStack {
                DatePicker(selection: $vm.date, in: Date()..., displayedComponents: [.date, .hourAndMinute]) {
                    HStack {
                        Image(systemName: "clock")
                            .frame(width: 30)
                        Text("Reminder")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func DailyNotificationView() -> some View {
        FlexibleCardView {
            VStack {
                DatePicker(selection: $vm.date, in: Date()..., displayedComponents: [.hourAndMinute]) {
                    HStack {
                        Image(systemName: "clock")
                            .frame(width: 30)
                        Text("Reminder")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func WeeklyNotificationView() -> some View {
        FlexibleCardView {
            VStack {
                HStack {
                    ForEach(notificationService.getWeekDays()) { day in
                        Button {
                            if vm.weekDays.contains(day.id) {
                                vm.weekDays.remove(day.id)
                            } else {
                                vm.weekDays.insert(day.id)
                            }
                        } label: {
                            Text(day.shortName)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .foregroundStyle(vm.weekDays.contains(day.id) ? .white : .black)
                                .background {
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundStyle(vm.weekDays.contains(day.id) ? Color("FrDefault") : .white)
                                }
                        }
                    }
                }
                DatePicker(selection: $vm.date, in: Date()..., displayedComponents: [.hourAndMinute]) {
                    HStack {
                        Image(systemName: "clock")
                            .frame(width: 30)
                        Text("Time")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func MonthlyNotificationView() -> some View {
        FlexibleCardView {
            VStack {
                Text("Monthly")
            }
        }
    }
    
    private func getTypeImage(_ type: NotificationType) -> String {
        switch type {
        case .exact:
            "bell"
        case .daily:
            "bell"
        case .weekly:
            "bell"
        case .monthly:
            "bell"
        }
    }
    
    private func getTypeName(_ type: NotificationType) -> String {
        switch type {
        case .exact:
            "One Time"
        case .daily:
            "Daily"
        case .weekly:
            "Weekly"
        case .monthly:
            "Monthly"
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
