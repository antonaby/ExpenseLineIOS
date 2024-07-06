//
//  PaywallView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 20.06.24.
//

import SwiftUI
import StoreKit


struct PaywallView: View {
    
    @EnvironmentObject var subscrioptionService: SubscriptionService
    @Environment(\.dismiss) var dismiss
    
    @State var products: [Product] = []
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "star.fill")
                Text("Premium")
            }
            .foregroundStyle(Color.appButtonTextColor)
            .padding(8)
            .font(.caption)
            .background(RoundedRectangle(cornerRadius: 7).foregroundStyle(Color.appLink))
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topTrailing) {
                ToolButton(icon: "x.circle", color: Color.appDestructiveLink) {
                    dismiss()
                }
                .font(.title2)
            }
            
            ScrollView {
                Text("Full Access")
                    .font(.title)
                PremiumAdvantagesRow(icon: "piggy-bank", text: "Unlimited budgets")
                PremiumAdvantagesRow(icon: "fl-shopping-cart", text: "Unlimited categories")
                PremiumAdvantagesRow(icon: "fl-other", text: "Unlimited transactions")
                PremiumAdvantagesRow(icon: "bell", text: "Unlimited reminders")
                Color.clear.frame(height: 35)
                VStack {
                    ForEach(products) { product in
                        Button {
                            Task {
                                await subscrioptionService.buyProduct(product)
                            }
                        } label: {
                            FlexibleCardView(color: Color.appLink) {
                                VStack {
                                    HStack {
                                        Text(product.displayName)
                                            .bold()
                                        Spacer()
                                        Text(product.displayPrice)
                                    }
                                    Text(product.description)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .foregroundStyle(Color.appButtonTextColor)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 15)
        .background(Color.appBackground)
        .task {
            let list = await subscrioptionService.allProducts()
            await MainActor.run {
                products = list
            }
        }
    }
    
    @ViewBuilder
    func PremiumAdvantagesRow(icon: String, color: Color = Color.appLink, text: String) -> some View {
        HStack {
            IconView(name: icon, color: color, size: 45)
                .frame(width: 50, height: 50)
            Text(text)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let bundle = ServiceBundle.preview
    
    return PaywallView()
        .serviceBundle(bundle)
}
