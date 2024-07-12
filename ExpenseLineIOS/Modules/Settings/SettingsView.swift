//
//  SettingsView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.05.24.
//

import SwiftUI

struct ColorSchemeView: View {
    
    @EnvironmentObject var analyticsService: AnalyticsService
    @Environment(\.dismiss) var dismiss
    @Binding var colorScheme: ColorScheme?
    
    var body: some View {
        Form {
            Button {
                colorScheme = nil
                analyticsService.logEvent(name: AnalyticsService.SETTGINS_COLOR_SCHEME, params: ["mode": "system"])
                dismiss()
            } label: {
                Label {
                    Text("System")
                        .foregroundStyle(Color.appCardTextColor)
                } icon: {
                    Image(systemName: "xmark")
                }
            }
            Button {
                colorScheme = .light
                analyticsService.logEvent(name: AnalyticsService.SETTGINS_COLOR_SCHEME, params: ["mode": "light"])
                dismiss()
            } label: {
                Label {
                    Text("Light")
                        .foregroundStyle(Color.appCardTextColor)
                } icon: {
                    Image(systemName: "sun.max")
                }
            }
            Button {
                colorScheme = .dark
                analyticsService.logEvent(name: AnalyticsService.SETTGINS_COLOR_SCHEME, params: ["mode": "dark"])
                dismiss()
            } label: {
                Label {
                    Text("Dark")
                        .foregroundStyle(Color.appCardTextColor)
                } icon: {
                    Image(systemName: "moon.stars")
                }
            }
        }
        .tint(Color.appLink)
        .background(Color.appBackground)
        .scrollContentBackground(.hidden)
    }
}

struct SettingsView: View {
    
    @EnvironmentObject var analyticsService: AnalyticsService
    @EnvironmentObject var subscriptioManager: SubscriptionManager
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State var helpButtonVisible: Bool
    @State var dailyReminderEnabled: Bool
    @State var dailyReminderTime: Date
    @State var colorScheme: ColorScheme?
    
    private let settings: SettingsService
    
    init(settings: SettingsService) {
        self.settings = settings
        
        self._helpButtonVisible = State(
            wrappedValue: settings.getBoolPreference(for: SettingsService.SHOW_HELP_BUTTON))
        self._dailyReminderEnabled = State(
            wrappedValue: settings.getBoolPreference(for: SettingsService.DAILY_REMINDER_ENABLED))
        self._dailyReminderTime = State(
            wrappedValue: settings.getDailyReminder())
        self._colorScheme = State(wrappedValue: settings.getColorScheme())
    }
    
    var body: some View {
        Form {
            Section {
                if subscriptioManager.hasProSubscription() {
                    Label {
                        Text("Premium")
                    } icon: {
                        Image(systemName: "star.fill")
                    }
                } else {
                    Button {
                        subscriptioManager.showPaywall()
                    } label: {
                        Label {
                            Text("Upgrade to Premium")
                        } icon: {
                            Image(systemName: "star")
                        }
                    }
                }
            } header: {
                Text("Subscription")
            }
            if let budget = appState.budget {
                Section {
                    Button {
                        appState.navigateEditBudget(budget)
                    } label: {
                        Label {
                            Text(budget.name ?? "Budget")
                        } icon: {
                            Image(systemName: "pencil")
                        }
                    }
                } header: {
                    Text("Budget")
                }
            }
            Section {
                NavigationLink {
                    ColorSchemeView(colorScheme: $colorScheme)
                        .navigationTitle("Color Scheme")
                } label: {
                    Label {
                        HStack {
                            Text("Color Scheme")
                            Spacer()
                            Text(getColorSchemeName())
                                .bold()
                        }
                    } icon: {
                        Image(systemName: "paintpalette")
                    }
                }
                .onChange(of: colorScheme) { value in
                    appState.setColorScheme(value)
                    settings.setColorScheme(value)
                }
                Toggle(isOn: $helpButtonVisible) {
                    Label {
                        Text("Show Help Button")
                    } icon: {
                        Image(systemName: "questionmark")
                    }
                }
                .onChange(of: helpButtonVisible) { value in
                    appState.helpButtonVisible(value)
                }
                Toggle(isOn: $dailyReminderEnabled) {
                    Label {
                        Text("Daily Reminder")
                    } icon: {
                        Image(systemName: "bell")
                    }
                }
                .onChange(of: dailyReminderEnabled) { value in
                    settings.setBoolPreference(for: SettingsService.DAILY_REMINDER_ENABLED, value: value)
                    if value {
                        notificationService.scheduleDailyReminder(date: dailyReminderTime)
                        analyticsService.logEvent(name: AnalyticsService.DAILY_REMINDER_ENABLED)
                    } else {
                        notificationService.cancelDailyReminder()
                        analyticsService.logEvent(name: AnalyticsService.DAILY_REMINDER_DISABLED)
                    }
                }
                if dailyReminderEnabled {
                    DatePicker(selection: $dailyReminderTime, displayedComponents: [.hourAndMinute]) {
                        Label {
                            Text("Remind me at")
                        } icon: {
                            Image(systemName: "clock")
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
        .tint(Color.appLink)
        .background(Color.appBackground)
        .scrollContentBackground(.hidden)
    }
    
    func getColorSchemeName() -> String {
        if let scheme = colorScheme {
            switch scheme {
            case .light:
                return "Light"
            case .dark:
                return "Dark"
            default:
                return "System"
            }
        }
        
        return "System"
    }
    
}

#Preview {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    budget.name = "Preview"
    
    let appState = AppState(bundle: bundle)
    appState.budget = budget
    
    return NavigationStack {
        SettingsView(settings: bundle.settingsService)
            .serviceBundle(bundle)
            .environmentObject(appState)
            .environmentObject(SubscriptionManager(analyticsService: bundle.analyticsService))
    }
}
