//
//  ProgressView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 17.05.24.
//

import SwiftUI

struct ProgressView: View {
    
    var progress: Double
    var color: Color
    var height: CGFloat
    
    init(progress: Double, color: Color = .green, fullColor: Color = .red, height: CGFloat = 10) {
        if progress >= 1 {
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
        self.height = height
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .foregroundColor(color.opacity(0.3))
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .frame(width: proxy.size.width * progress, alignment: .leading)
                    .foregroundColor(color)
            }
        }.frame(maxHeight: height)
    }
    
}

#Preview("0%") {
    ProgressView(progress: 0)
}

#Preview("30%") {
    ProgressView(progress: 0.3)
}

#Preview("Full") {
    ProgressView(progress: 1)
}
