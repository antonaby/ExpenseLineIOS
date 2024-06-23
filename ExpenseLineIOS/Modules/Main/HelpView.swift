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
                switch page {
                case .mainWizard:
                    MainWizardPage()
                case .incomeWizard:
                    ImcomeWizardPage()
                case .fixedOutcomeWizard:
                    OutcomeFixedWizardPage()
                case .flexibleOutcomeWizard:
                    OutcomeFlexibleWizardPage()
                case .mainPage:
                    Text("")
                }
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
    
    @ViewBuilder
    func MainWizardPage() -> some View {
        Text("Let's create a new budget")
    }
    
    @ViewBuilder
    func ImcomeWizardPage() -> some View {
        Text("It's your income")
    }
    
    @ViewBuilder
    func OutcomeFixedWizardPage() -> some View {
        Text("It's your montly outcome")
    }
    
    @ViewBuilder
    func OutcomeFlexibleWizardPage() -> some View {
        Text("It's your flexible outocmes")
    }
    
    @ViewBuilder
    func MainPage() -> some View {
        Text("It's your budget")
    }
    
}

#Preview {
    HelpView(page: .mainWizard)
}
