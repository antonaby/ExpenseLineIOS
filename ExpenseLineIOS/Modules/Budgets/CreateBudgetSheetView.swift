//
//  CreateBudgetSheetView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import SwiftUI

struct CreateBudgetSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: CreateBudgetSheetViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                Spacer()
                AddArrowButton {
                    vm.createBudget()
                    dismiss()
                }
                .disabled(!vm.isValid)
            }
            .padding([.horizontal, .top], 15)
            Form {
                Section {
                    TextField(text: $vm.name) {
                        Text("Name")
                    }
                    Picker("Currency", selection: $vm.currecny) {
                        ForEach(vm.getCurrencies(), id: \.self) { currency in
                            Text(currency)
                        }
                    }
                    Picker("Type", selection: $vm.type) {
                        ForEach(PlanType.allCases) { type in
                            Text("\(type)")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CreateBudgetSheetView(vm: DependencyResolver.preview.createBudgetSheetViewModel())
}
