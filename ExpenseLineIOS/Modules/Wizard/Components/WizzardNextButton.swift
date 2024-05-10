//
//  WizzardNextButton.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.04.24.
//

import SwiftUI

struct WizzardNextButton: View {
    
    private let label: String
    private let action: () -> Void
    
    init(_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .font(.title2)
                .frame(maxWidth: .infinity)
                
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
    }
}

#Preview {
    WizzardNextButton("Next", action: { print("Preview") })
}
