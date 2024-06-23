//
//  HelpButton.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 23.06.24.
//

import SwiftUI

struct HelpButton: View {
    
    let action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "questionmark")
                .foregroundStyle(.white)
                .padding(5)
                .font(.caption)
                .background(Circle().foregroundStyle(Color("FrDefault")))
        }
    }
}

#Preview {
    HelpButton {
        print("Preview")
    }
}
