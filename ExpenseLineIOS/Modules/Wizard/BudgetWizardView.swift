//
//  BudgetWizardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.04.24.
//

import SwiftUI

struct NextButtonView: View {
    
    private let label: String
    private let action: () -> Void
    
    init(_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
        }
        .buttonStyle(.borderless)
    }
    
}


struct BudgetWizardView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: BudgetWizardViewModel = BudgetWizardViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    vm.previousPage()
                } label: {
                    Label("Back", systemImage: "chevron.backward")
                }
                .disabled(vm.currentStageIndex == 0)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Label("Close", systemImage: "xmark")
                        .foregroundColor(Color.red)
                }
            }
            .padding([.horizontal], 10)
            TabView(selection: $vm.currentStageIndex) {
                initialPageView().tag(0)
                incomePageView().tag(1)
                scopeSelectorView().tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            NextButtonView(nextButtonCaption()) {
                if vm.currentStageIndex == 2 {
                    dismiss()
                } else {
                    vm.nextPage()
                }
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
    
    func nextButtonCaption() -> String {
        return vm.currentStageIndex < 2 ? "Next" : "Create"
    }
    
    @ViewBuilder
    func initialPageView() -> some View {
        Form {
            Section {
                TextField("Name", text: $vm.name)
                Picker("Currency", selection: $vm.currency) {
                    ForEach(vm.getCurrencies(), id: \.self) { currency in
                        Text(currency)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func incomePageView() -> some View {
        VStack {
            Text("Income")
        }
    }
    
    @ViewBuilder
    func scopeSelectorView() -> some View {
        VStack {
            Text("Scopes")
        }
    }
    
}

#Preview {
    BudgetWizardView()
}
