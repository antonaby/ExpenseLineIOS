//
//  FlexibleCardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 02.05.24.
//

import SwiftUI

struct FlexibleCardView<Content: View>: View {
    
    private let cornerRadius: CGFloat
    private let padding: CGFloat
    private let color: Color
    private let content: Content
    
    init(cornerRadius: CGFloat = 10, padding: CGFloat = 10, color: Color = Color.backgroundSecondary, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: cornerRadius).fill(color)
            content
                .padding(padding)
        }
    }
    
}
