//
//  AddSpaceCircle.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI

struct AddSpaceCircle: View {
    
    let action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "plus")
                .foregroundColor(.black)
                .frame(width: 60, height: 60)
                .font(.title)
                .background(Color(uiColor: .lightGray))
                .clipShape(Circle())
        }
    }
    
}

#Preview {
    AddSpaceCircle { print("Nothing") }
}
