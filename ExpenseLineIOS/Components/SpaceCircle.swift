//
//  SpaceCircle.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI

struct SpaceCircle: View {
    
    let name: String
    
    var body: some View {
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

#Preview {
    SpaceCircle(name: "Test")
}
