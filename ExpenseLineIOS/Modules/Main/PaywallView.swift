//
//  PaywallView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 20.06.24.
//

import SwiftUI
import StoreKit


struct PaywallView: View {
    
    @EnvironmentObject var analyticsService: AnalyticsService
    @EnvironmentObject var subscrioptionManager: SubscriptionManager
    @Environment(\.dismiss) var dismiss
    
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
                    analyticsService.logEvent(name: AnalyticsService.PAYWALL_CLOSED)
                    dismiss()
                }
                .font(.title2)
                .accessibilityLabel("Close")
                .accessibilityElement(children: .combine)
            }
            ScrollView {
                Text("Open Full Access")
                    .font(.title)
                PremiumAdvantagesRow(icon: "piggy-bank", text: "Unlimited Budgets")
                PremiumAdvantagesRow(icon: "fl-shopping-cart", text: "Unlimited Categories")
                PremiumAdvantagesRow(icon: "fl-other", text: "Unlimited Expense Records")
                PremiumAdvantagesRow(icon: "bell", text: "Unlimited Reminders")
                Color.clear.frame(height: 35)
                VStack {
                    ForEach(subscrioptionManager.products) { product in
                        Button {
                            Task {
                                await subscrioptionManager.buyProduct(product)
                            }
                        } label: {
                            FlexibleCardView {
                                VStack {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading) {
                                            Text(product.displayName)
                                                .bold()
                                            Text(product.description)
                                                .font(.caption)
                                        }
                                        Spacer()
                                        VStack {
                                            Text(product.displayPrice)
                                                .padding(5)
                                                .foregroundStyle(Color.appButtonTextColor)
                                                .background(RoundedRectangle(cornerRadius: 5).foregroundStyle(Color.appLink))
                                        }
                                    }
                                }
                            }
                            .foregroundStyle(Color.appCardTextColor)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 15)
        .background(Color.appBackground)
        .task {
            await subscrioptionManager.fetchProducts()
        }
        .onAppear {
            analyticsService.logEvent(name: AnalyticsService.PAYWALL_OPEN)
        }
    }
    
    @ViewBuilder
    func PremiumAdvantagesRow(icon: String, color: Color = Color.appLink, text: String) -> some View {
        HStack {
            IconView(name: icon, color: color, size: 45)
                .frame(width: 50, height: 50)
                .accessibilityHidden(true)
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
        .environmentObject(SubscriptionManager(analyticsService: bundle.analyticsService))
}
