//
//  WizzardNextButton.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.04.24.
//

import SwiftUI

struct WizardButtonContentViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .frame(maxWidth: .infinity, minHeight: 35)
    }
    
    static let modifier = WizardButtonContentViewModifier()
    
}

struct WizzardNextButton<Content: View>: View {
    
    @Environment(\.isEnabled) var isEnabled
    
    private let action: () -> Void
    private let content: Content
    
    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            content
        }
        .buttonStyle(.borderedProminent)
        .tint(buttonColor())
    }
    
    private func buttonColor() -> Color {
        if isEnabled {
            return Color("FrDefault")
        }
        
        return Color.gray
    }
}

#Preview {
    WizzardNextButton() {
        print("Preview")
    } content: {
        Text("Preview")
            .modifier(WizardButtonContentViewModifier.modifier)
    }
}
