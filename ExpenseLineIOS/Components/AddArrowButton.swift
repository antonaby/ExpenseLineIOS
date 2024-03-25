//
//  AddArrowButton.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI

struct AddArrowButton: View {
    
    @Environment(\.isEnabled) var isEnabled
    
    let action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "arrow.up")
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .background(bacgroundColor())
                .clipShape(Circle())
        }
    }
    
    func bacgroundColor() -> some View {
        if isEnabled {
            return Color.red
        }
        
        return Color.gray
    }
    
}

#Preview {
    AddArrowButton { print("Nothing") }
}
