//
//  FormTitleViewModifier.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 10.05.24.
//

import Foundation
import SwiftUI

struct FormTitleViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.title)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    static let modifier = FormTitleViewModifier()
    
}

struct FormTipViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    static let modifier = FormTipViewModifier()
    
}


