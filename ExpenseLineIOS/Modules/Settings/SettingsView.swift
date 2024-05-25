//
//  SettingsView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.05.24.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                ToolButton(icon: "x.circle", color: .gray) {
                    dismiss()
                }
                .font(.title2)
            }
            .padding(.horizontal, 5)
            ScrollView {
                VStack {
                    Text("Settings")
                }
            }
        }
    }
    
}

#Preview {
    SettingsView()
}
