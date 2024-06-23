//
//  HelpView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 23.06.24.
//

import SwiftUI

struct HelpView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var page: HelpPage
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "questionmark")
                    .foregroundStyle(.white)
                    .padding(5)
                    .font(.caption)
                    .background(Circle().foregroundStyle(Color("FrDefault")))
                Text("Help")
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topTrailing) {
                ToolButton(icon: "x.circle", color: Color("Accent1")) {
                    dismiss()
                }
                .font(.title2)
            }
            ScrollView {
                Text("Info")
                    .bold()
            }
            Button {
                dismiss()
            } label: {
                Text("Understand")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .foregroundStyle(.white)
                    .background(RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color("FrDefault")))
            }
            .padding(.horizontal, 25)
        }
        .padding(.top, 15)
        .padding(.horizontal, 15)
        .background(Color("BgDefault"))
    }
    
}

#Preview {
    HelpView(page: .mainWizard)
}
