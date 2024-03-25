//
//  CreateSpaceSheetView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI


struct CreateSpaceSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: CreateSpaceSheetViewModel = CreateSpaceSheetViewModel()
    
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
                    vm.createSpace()
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
    CreateSpaceSheetView()
}
