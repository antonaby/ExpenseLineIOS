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
    
    @Binding var currency: String
    @State var currecnies: [CurrencyLocale] = []
    
    var body: some View {
        List {
            ForEach(currecnies) { currencyLocale in
                Button {
                    currency = currencyLocale.id
                    dismiss()
                } label: {
                    HStack {
                        Text(currencyLocale.symbol)
                            .bold()
                        Text(currencyLocale.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            let ds = resolver.dataService()
            currecnies = ds.getCurrencies()
        }
    }
}

#Preview {
    CurrencySelectorSheet(currency: .constant("en_US"))
        .environmentObject(DependencyResolver.preview)
}
