//
//  AddExpenseButton.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI

struct AddExpenseButton: View {
    
    let action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
        
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "plus")
                .font(.title.weight(.semibold))
                .padding(15)
                .background(.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

#Preview {
    AddExpenseButton({ print("Nothing") })
}
