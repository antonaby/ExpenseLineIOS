//
//  BaseCardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.05.24.
//

import SwiftUI

struct ContentSizeCardView<Content: View>: View {
    
    private let cornerRadius: CGFloat
    private let padding: CGFloat
    private let color: Color
    private let content: Content
    
    init(cornerRadius: CGFloat = 10, padding: CGFloat = 10, color: Color = .white, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        Group {
            content
                .padding(padding)
        }
        .background(RoundedRectangle(cornerRadius: cornerRadius).fill(color))
    }
}
