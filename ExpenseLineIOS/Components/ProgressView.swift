//
//  ProgressView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 17.05.24.
//

import SwiftUI

struct ProgressView: View {
    
    var percent: Double
    var color: Color
    var height: CGFloat
    
    init(percent: Double, color: Color = .green, height: CGFloat = 10) {
        self.percent = percent
        self.color = color
        self.height = height
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .foregroundColor(color.opacity(0.3))
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .frame(width: proxy.size.width * percent, alignment: .leading)
                    .foregroundColor(color)
            }
        }.frame(maxHeight: height)
    }
    
}

#Preview {
    ProgressView(percent: 0.3)
}
