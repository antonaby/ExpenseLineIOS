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
    @EnvironmentObject var analyticsService: AnalyticsService
    
    @StateObject var vm: EditNotificationSheetViewModel
    
    var body: some View {
        VStack {
            HStack {
                ToolButton(icon: "x.circle", color: Color.appDestructiveLink) {
                    vm.rollback()
                    dismiss()
                }
                .accessibilityLabel("Close")
                .accessibilityElement(children: .combine)
                Spacer()
                Text("Reminder")
                    .font(.headline)
                Spacer()
                ToolButton(color: Color.appLink) {
                    if vm.notification.isNew {
                        analyticsService.logEvent(name: AnalyticsService.NOTIFICATION_CREATED)
                    } else {
                        analyticsService.logEvent(name: AnalyticsService.NOTIFICATION_EDITED)
                    }
                    vm.save()
                    dismiss()
                }
                .disabled(!vm.isValid)
                .accessibilityLabel("Save")
                .accessibilityElement(children: .combine)
            }
            .padding([.horizontal, .top], 10)
            .padding([.bottom], 5)
            .font(.title2)
            NavigationStack {
                ScrollView {
                    VStack {
                        FlexibleCardView {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "pencil")
                                        .frame(width: 30)
                                        .foregroundStyle(Color.appLink)
                                    TextField("Name", text: $vm.name)
                                }
                            }
                        }
                        if !vm.categories.isEmpty {
                            FlexibleCardView {
                                VStack {
                                    NavigationLink {
                                        CategorySelectorView(category: $vm.category, categories: $vm.categories)
                                    } label: {
                                        if let category = vm.category {
                                            HStack {
                                                IconView(name: category.iconNameValue)
                                                    .accessibilityLabel(category.nameValue)
                                                Text(category.nameValue)
                                                    .frame(height: 45)
                                                    .font(.title2)
                                                Spacer()
                                            }
                                            .frame(maxWidth: .infinity)
                                            .overlay(alignment: .trailing) {
                                                Button {
                                                    vm.category = nil
                                                } label: {
                                                    Text("remove")
                                                        .font(.caption)
                                                        .foregroundStyle(Color.appLink)
                                                }
                                            }
                                        } else {
                                            HStack {
                                                Text("No Category")
                                                    .frame(height: 45)
                                                    .font(.title2)
                                            }
                                        }
                                    }
                                    .foregroundStyle(Color.appCardTextColor)
                                }
                            }
                        }
                        NotificationTypeCardView()
                        if vm.type != .nonotification {
                            FlexibleCardView {
                                HStack {
                                    Toggle("Enabled", isOn: $vm.enabled)
                                        .tint(Color.appLink)
                                }
                            }
                        }
                        switch vm.type {
                        case .exact:
                            ExactNotificationView()
                        case .daily:
                            DailyNotificationView()
                        case .weekly:
                            WeeklyNotificationView()
                        case .nonotification:
                            NoNotificationView()
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 15)
                    Button {
                        vm.deleteNotification()
                        dismiss()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .tint(Color.appDestructiveLink)
                    }
                    
                }
                .background(Color.appBackground)
            }
        }
        .background(Color.appBackgroundSecondary)
        .interactiveDismissDisabled(true)
        .onAppear {
            vm.loadCategories()
        }
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
                        .foregroundStyle(vm.type == type ? Color.appLink : Color.appCardTextColor)
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
                            .foregroundStyle(Color.appLink)
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
                DatePicker(selection: $vm.date, displayedComponents: [.hourAndMinute]) {
                    HStack {
                        Image(systemName: "clock")
                            .frame(width: 30)
                            .foregroundStyle(Color.appLink)
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
                HStack(spacing: 5) {
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
                                .foregroundStyle(vm.weekDays.contains(day.id) ? Color.appLink : Color.appLinkInactive)
                                .background {
                                    RoundedRectangle(cornerRadius: 7)
                                        .foregroundStyle(vm.weekDays.contains(day.id) ? Color.appBackground: Color.appBackgroundSecondary)
                                }
                        }
                    }
                }
                DatePicker(selection: $vm.date, displayedComponents: [.hourAndMinute]) {
                    HStack {
                        Image(systemName: "clock")
                            .frame(width: 30)
                            .foregroundStyle(Color.appLink)
                        Text("Time")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func NoNotificationView() -> some View {
        EmptyView()
    }
    
    private func getTypeImage(_ type: NotificationType) -> String {
        switch type {
        case .nonotification:
            "bell.slash"
        case .exact:
            "bell"
        case .daily:
            "bell"
        case .weekly:
            "bell"
        }
    }
    
    private func getTypeName(_ type: NotificationType) -> String {
        switch type {
        case .nonotification:
            "No signal"
        case .exact:
            "One Time"
        case .daily:
            "Daily"
        case .weekly:
            "Weekly"
        }
    }
    
}

#Preview("New") {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    
    let category1 = bundle.budgetService.newCategoryEntity(budget)
    category1.id = UUID()
    category1.name = "Preview 1"
    category1.amount = 0
    category1.percent = 0.2
    category1.iconName = "fi-house"
    category1.typeValue = .outcomePercent
    category1.createdAt = Date()
    
    let category2 = bundle.budgetService.newCategoryEntity(budget)
    category2.id = UUID()
    category2.name = "Preview 2"
    category2.amount = 2000
    category2.percent = 0
    category2.iconName = "fi-insurance"
    category2.typeValue = .outcomeFixed
    category2.createdAt = Date()
    
    let notification = bundle.notificationService.newNotificationEntity(budget)
    notification.typeValue = .exact
    notification.enabled = true
    
    let vm = EditNotificationSheetViewModel(
        notification: notification,
        notificationService: bundle.notificationService,
        analyticsService: bundle.analyticsService
    )
    
    return EditNotificationSheetView(vm: vm)
        .serviceBundle(bundle)
}
