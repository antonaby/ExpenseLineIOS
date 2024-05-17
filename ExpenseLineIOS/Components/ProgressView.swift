//
//  ProgressView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 17.05.24.
//

import SwiftUI

struct ProgressView: View {
    
    var percent: Double
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .foregroundColor(.green)
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .frame(width: proxy.size.width * percent, alignment: .leading)
                    .foregroundColor(.red)
            }
        }.frame(maxHeight: 10)
    }
    
}
