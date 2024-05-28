//
//  CircularProgressView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.05.24.
//

import SwiftUI

struct CircularProgressView<Content: View>: View {
    
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    private let content: Content
    
    init(progress: Double,
         color: Color = .green,
         fullColor: Color = .red,
         lineWidth: CGFloat = 15,
         @ViewBuilder content: @escaping () -> Content) {
        if progress > 1 {
            self.progress = 1
            self.color = fullColor
        } else {
            if progress < 0 {
                self.progress = 0
            } else {
                self.progress = progress
            }
            self.color = color
        }
        self.lineWidth = lineWidth
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.3),
                    lineWidth: lineWidth
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            content
        }
    }
}

#Preview("0%") {
    CircularProgressView(progress: 0, content: { Text("Preview") })
        .frame(width: 100, height: 100)
}

#Preview("20%") {
    CircularProgressView(progress: 0.2, content: { Text("Preview") })
        .frame(width: 100, height: 100)
}

#Preview("Full") {
    CircularProgressView(progress: 1, content: { Text("Preview") })
        .frame(width: 100, height: 100)
}

#Preview("Full 120%") {
    CircularProgressView(progress: 1.2, content: { Text("Preview") })
        .frame(width: 100, height: 100)
}
