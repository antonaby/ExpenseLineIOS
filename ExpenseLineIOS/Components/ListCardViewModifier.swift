//
//  ListCardViewModifier.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 16.06.24.
//

import Foundation
import SwiftUI

struct ListCardViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color("BgDefault"))
            .listRowInsets(.init())
            .listRowSeparator(.hidden)
    }
    
}

extension View {
    
    func defaultListCard() -> some View {
        self.modifier(ListCardViewModifier())
    }
    
}
