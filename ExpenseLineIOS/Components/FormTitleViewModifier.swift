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
            .foregroundColor(Color.appCardTextColor)
    }
    
    static let modifier = FormTitleViewModifier()
    
}

