//
//  SettingsView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.05.24.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State var helpButtonVisible: Bool
    @State var dailyReminderEnabled: Bool
    @State var dailyReminderTime: Date
    
    private let settings: SettingsService
    
    init(settings: SettingsService) {
        self.settings = settings
        
        self._helpButtonVisible = State(
            wrappedValue: settings.getBoolPreference(for: SettingsService.SHOW_HELP_BUTTON))
        self._dailyReminderEnabled = State(
            wrappedValue: settings.getBoolPreference(for: SettingsService.DAILY_REMINDER_ENABLED))
        self._dailyReminderTime = State(
            wrappedValue: settings.getDailyReminder())
    }
    
    var body: some View {
        VStack {
            Form {
                if let budget = appState.budget {
                    Section {
                        Button {
                            appState.navigateEditBudget(budget)
                        } label: {
                            Text("Edit **\(budget.name ?? "Budget")**")
                        }
                        .tint(.black)
                    } header: {
                        Text("Budget")
                    }
                }
                Section {
                    Toggle(isOn: $helpButtonVisible) {
                        Label {
                            Text("Help button")
                        } icon: {
                            Image(systemName: "questionmark")
                                .foregroundStyle(Color("FrDefault"))
                        }
                    }
                    .tint(Color("FrDefault"))
                    .onChange(of: helpButtonVisible) { value in
                        appState.helpButtonVisible(value)
                    }
                    Toggle(isOn: $dailyReminderEnabled) {
                        Label {
                            Text("Daily Reminder")
                        } icon: {
                            Image(systemName: "bell")
                                .foregroundStyle(Color("FrDefault"))
                        }
                    }
                    .tint(Color("FrDefault"))
                    .onChange(of: dailyReminderEnabled) { value in
                        settings.setBoolPreference(for: SettingsService.DAILY_REMINDER_ENABLED, value: value)
                        if value {
                            notificationService.scheduleDailyReminder(date: dailyReminderTime)
                        } else {
                            notificationService.cancelDailyReminder()
                        }
                    }
                    if dailyReminderEnabled {
                        DatePicker(selection: $dailyReminderTime, displayedComponents: [.hourAndMinute]) {
                            Label {
                                Text("Remind me at")
                            } icon: {
                                Image(systemName: "clock")
                                    .foregroundStyle(Color("FrDefault"))
                            }
                        }
                        .onChange(of: dailyReminderTime) { value in
                            if dailyReminderEnabled {
                                notificationService.cancelDailyReminder()
                                notificationService.scheduleDailyReminder(date: value)
                                settings.setDailyReminder(date: value)
                            } 
                        }
                    }
                } header: {
                    Text("Settings")
                }
            }
            .background(Color("BgDefault"))
            .scrollContentBackground(.hidden)
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
    
}

#Preview {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    budget.name = "Preview"
    
    let appState = AppState(bundle: bundle)
    appState.budget = budget
    
    return SettingsView(settings: bundle.settingsService)
        .serviceBundle(bundle)
        .environmentObject(appState)
}
