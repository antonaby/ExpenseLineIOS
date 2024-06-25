//
//  SettingsView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.05.24.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var settings: SettingsService
    @Environment(\.dismiss) var dismiss
    
    @State var isHelpButtonVisible: Bool = false
    
    @State var preferences: [BoolUserPreference] = [
        
    ]
    
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
                    Toggle(isOn: $isHelpButtonVisible) {
                        Text("Show help")
                    }
                    .tint(Color("FrDefault"))
                    .onChange(of: isHelpButtonVisible) { value in
                        appState.helpButtonVisible(value)
                    }
                    
                    ForEach($preferences) { $preference in
                        Toggle(preference.name, isOn: $preference.value)
                            .onChange(of: preference.value) { value in
                                settings.setBoolPreference(for: preference.id, value: value)
                            }
                            .tint(Color("FrDefault"))
                    }
                } header: {
                    Text("Appearance")
                }
            }
            .background(Color("BgDefault"))
            .scrollContentBackground(.hidden)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .onAppear {
            isHelpButtonVisible = settings.getBoolPreference(for: SettingsService.SHOW_HELP_BUTTON)
            
            preferences = preferences.map {
                BoolUserPreference(
                    id: $0.id,
                    name: $0.name,
                    value: settings.getBoolPreference(for: $0.id)
                )
            }
        }
    }
    
}

#Preview {
    let bundle = ServiceBundle.preview
    let budget = bundle.budgetService.newBudgetEntity()
    budget.name = "Preview"
    
    let appState = AppState(bundle: bundle)
    appState.budget = budget
    
    return SettingsView()
        .serviceBundle(bundle)
        .environmentObject(appState)
}
