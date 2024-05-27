//
//  SettingsView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.05.24.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var settings: SettingsService
    @Environment(\.dismiss) var dismiss
    
    @State var preferences: [BoolUserPreference] = [
        BoolUserPreference(id: SettingsService.GAPS_IN_CIRCLE, name: "Gaps In Circle", value: false)
    ]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                ToolButton(icon: "x.circle", color: .gray) {
                    dismiss()
                }
                .font(.title2)
            }
            .padding(.horizontal, 20)
            Form {
                Section {
                    ForEach($preferences) { $preference in
                        Toggle(preference.name, isOn: $preference.value)
                            .onChange(of: preference.value) { value in
                                settings.setBoolPreference(for: preference.id, value: value)
                            }
                    }
                } header: {
                    Text("Appearance")
                }
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .onAppear {
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
    
    return SettingsView()
        .serviceBundle(bundle)
}
