//
//  IconView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 27.05.24.
//

import SwiftUI

struct IconView: View {
    
    var name: String
    var color: Color = .black
    var size: CGFloat = 35
    
    var body: some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
            .frame(width: size, height: size)
    }
    
}

#Preview {
    VStack {
        IconView(name: "piggy-bank", color: .cyan)
        IconView(name: "piggy-bank", color: .green, size: 50)
        IconView(name: "piggy-bank", color: .purple, size: 100)
    }
}
