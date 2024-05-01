//
//  BaseCardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.05.24.
//

import SwiftUI

struct BaseCardView<Content: View>: View {
    
    private var content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            content
                .padding()
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(.white))
    }
}
