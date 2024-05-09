//
//  TooltipCardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 03.05.24.
//

import SwiftUI

struct PromptView<Content: View>: View {
    
    private let cornerRadius: CGFloat
    private let padding: CGFloat
    private let color: Color
    private let content: () -> Content
    @State private var closed: Bool
    
    init(cornerRadius: CGFloat = 10,
         padding: CGFloat = 10,
         color: Color = .white,
         closed: Bool = false,
         @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.color = color
        self._closed = State(initialValue: closed)
        self.content = content
    }
    
    var body: some View {
        if !closed {
            ZStack(alignment: .topTrailing) {
                //RoundedRectangle(cornerRadius: cornerRadius).fill(color)
                ToolButton(icon: "x.circle", color: .gray) {
                    withAnimation {
                        closed.toggle()
                    }
                }
                .padding([.trailing, .top], 5)
                .font(.title3)
                content()
                    .frame(maxWidth: .infinity)
                    .padding(padding)
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    PromptView {
        Text("Test")
            .frame(maxWidth: .infinity)
    }
}
