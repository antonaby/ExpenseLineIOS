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
            TextField(text: $vm.name) {
                Text("Name")
            }
            Spacer()
        }
        .padding([.horizontal, .top], 15)
    }
}

#Preview {
    CreateBudgetSheetView(vm: DependencyResolver.preview.createBudgetSheetViewModel())
}
