//
//  AddArrowButton.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI

struct ToolButton: View {
    
    @Environment(\.isEnabled) var isEnabled
    
    let icon: String
    let color: Color
    let action: () -> Void
    
    init(icon: String = "checkmark", color: Color = .blue, action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .foregroundColor(iconColor())
        }
    }
    
    private func iconColor() -> Color {
        if isEnabled {
            return color
        }
        
        return Color.appLinkInactive
    }
    
}

#Preview {
    ToolButton(icon: "checkmark") { print("Nothing") }
}
