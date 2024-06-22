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

    ]
    
    var body: some View {
        VStack {
            Form {
                Section {
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
