//
//  CurrencySelectorSheet.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.05.24.
//

import SwiftUI

struct CurrencySelectorSheet: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var resolver: DependencyResolver
    
    @Binding var currency: CurrencySymbol
    @State var currecnies: [CurrencySymbol] = []
    
    var body: some View {
        List {
            ForEach(currecnies) { currencySymbol in
                Button {
                    currency = currencySymbol
                    dismiss()
                } label: {
                    HStack {
                        Text(currencySymbol.name)
                        Text(currencySymbol.symbol)
                            .bold()
                        Spacer()
                        Text(currencySymbol.code)
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .listStyle(.grouped)
        .onAppear {
            let ds = resolver.dataService()
            currecnies = ds.getCurrencies()
        }
    }
}

#Preview {
    CurrencySelectorSheet(
        currency: .constant(CurrencySymbol(id: "en_US", name: "United States"))
    )
        .environmentObject(DependencyResolver.preview)
}
