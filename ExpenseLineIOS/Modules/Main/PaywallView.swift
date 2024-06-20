//
//  PaywallView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 20.06.24.
//

import SwiftUI

struct PaywallView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                ToolButton(icon: "x.circle", color: Color("Accent1")) {
                    dismiss()
                }
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 15)
            }
            Text("Consider pay us money!!!")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color("BgDefault"))
    }
}

#Preview {
    PaywallView()
}
