//
//  CirclularBudgetProgressView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 21.05.24.
//

import SwiftUI

struct CirclularBudgetProgressView<Content: View>: View {
    
    let progress: [Double]
    let colors: [Color]
    let lineWidth: CGFloat
    
    private let multiplier: Int
    private let content: Content
    
    init(
        progress: [Double], colors: [Color], lineWidth: CGFloat = 15, gap: Bool,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.progress = progress.map {
            if $0 > 1 { return 1 }
            if $0 < 0 { return 0 }
            return $0
        }
        
        self.colors = colors
        self.lineWidth = lineWidth
        self.content = content()
        self.multiplier = gap ? 3 : 2
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(progress.enumerated()), id: \.offset) { index, progress in
                    Circle()
                        .stroke(getColor(index, progress: progress).opacity(0.3), lineWidth: lineWidth)
                        .frame(
                            width: geometry.size.width - lineWidth * CGFloat(multiplier * index),
                            height: geometry.size.height - lineWidth * CGFloat(multiplier * index)
                        )
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            getColor(index, progress: progress),
                            style: StrokeStyle(
                                lineWidth: lineWidth,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(
                            width: geometry.size.width - lineWidth * CGFloat(multiplier * index),
                            height: geometry.size.height - lineWidth * CGFloat(multiplier * index)
                        )
                }
                content
            }
        }
    }
    
    func getColor(_ i: Int, progress: Double) -> Color {
        if colors.count > i {
            return colors[i]
        }
        
        return colors.last ?? .black
    }
}

#Preview("OK") {
    CirclularBudgetProgressView(
        progress: [0.3, 0.7, 0.5],
        colors: [.orange, .purple, .green], gap: true) {
            Text("Preview")
        }
        .frame(width: 300, height: 300)
}

#Preview("OK No Gap") {
    CirclularBudgetProgressView(
        progress: [0.3, 0.7, 0.5],
        colors: [.orange, .purple, .green], gap: false) {
            Text("Preview")
        }
        .frame(width: 300, height: 300)
}

#Preview("FullPartially") {
    CirclularBudgetProgressView(
        progress: [0.4, 0.9, 1],
        colors: [.orange, .purple, .green], gap: true) {
            Text("Preview")
        }
        .frame(width: 300, height: 300)
}

#Preview("Full") {
    CirclularBudgetProgressView(
        progress: [1, 1, 1],
        colors: [.orange, .purple, .green], gap: true) {
            Text("Preview")
        }
        .frame(width: 300, height: 300)
}
