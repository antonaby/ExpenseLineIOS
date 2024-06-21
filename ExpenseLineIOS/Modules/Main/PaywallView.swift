//
//  PaywallView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 20.06.24.
//

import SwiftUI



struct PaywallView: View {
    
    @EnvironmentObject var subscrioptionService: SubscriptionService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "star.fill")
                Text("Premium")
            }
            .foregroundStyle(.white)
            .padding(8)
            .font(.caption)
            .background(RoundedRectangle(cornerRadius: 7).foregroundStyle(Color("FrDefault")))
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topTrailing) {
                ToolButton(icon: "x.circle", color: Color("Accent1")) {
                    dismiss()
                }
                .font(.title2)
            }
            
            ScrollView {
                Text("Full Access")
                    .font(.title)
                PremiumAdvantagesRow(icon: "piggy-bank", text: "Unlimited budgets")
                PremiumAdvantagesRow(icon: "fl-shopping-cart", text: "Unlimited categories")
                Color.clear.frame(height: 35)
                VStack {
                    Text("7 day free trial. **Auto-renews at \(subscrioptionService.getStandartSubsctiprionCost()).** No commitment. Cancel anytime.")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                    Button {
                        
                    } label: {
                        Text("Try for free and subscribe")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("FrDefault"))
                    Button {
                        
                    } label: {
                        Text("Restore")
                            .foregroundStyle(Color("FrDefault"))
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .padding(.horizontal, 15)
        .background(Color("BgDefault"))
    }
    
    @ViewBuilder
    func PremiumAdvantagesRow(icon: String, color: Color = Color("FrDefault"), text: String) -> some View {
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
