//
//  CircularProgressView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.05.24.
//

import SwiftUI

struct CircularProgressView: View {
    
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    
    init(progress: Double, color: Color = .green, lineWidth: CGFloat = 15) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
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
        }
    }
}

#Preview {
    CircularProgressView(progress: 0.2)
        .frame(width: 100, height: 100)
}
