//
//  SpaceCircle.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI

struct SpaceCircle: View {
    
    let name: String
    let action: () -> Void
    
    init(_ name: String, action: @escaping () -> Void) {
        self.name = name
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Circle()
                    .frame(maxWidth: 60, maxHeight: 60)
                    .foregroundColor(.green)
                Text(name)
                    .font(.callout)
                    .foregroundColor(.black)
            }
        }
    }
}

#Preview {
    SpaceCircle("Test") {
        print("Nothing")
    }
}
