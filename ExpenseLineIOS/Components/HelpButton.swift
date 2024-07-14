//
//  HelpButton.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 23.06.24.
//

import SwiftUI

struct HelpButtonVisible: EnvironmentKey {
    
    static var defaultValue: Bool?
    
}

extension EnvironmentValues {
        
    var helpButtonVisible: Bool? {
        get {
            self[HelpButtonVisible.self]
        }
        set {
            self[HelpButtonVisible.self] = newValue
        }
    }
    
}

extension View {
    
    func helpButtonVisible(_ value: Bool) -> some View {
        self.environment(\.helpButtonVisible, value)
    }
    
}


struct HelpButton: View {
    
    @Environment(\.helpButtonVisible) var visible
    
    let action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        if let isVisible = visible, isVisible {
            Button {
                action()
            } label: {
                Image(systemName: "questionmark")
                    .foregroundStyle(Color.appButtonTextColor)
                    .padding(5)
                    .font(.caption)
                    .background(Circle().foregroundStyle(Color.appLink))
            }
            .accessibilityLabel("Help")
        } else {
            EmptyView()
        }
    }
}

#Preview("Visible") {
    HelpButton {
        print("Preview")
    }
    .helpButtonVisible(true)
}
