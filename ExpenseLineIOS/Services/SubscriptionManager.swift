//
//  SubscriptionManager.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 08.07.24.
//

import Foundation
import StoreKit


@MainActor class SubscriptionManager: ObservableObject {
    
    @Published var paywall: Bool = false
    @Published var products: [Product] = []
    @Published var activeTransactions: Set<Transaction> = []
    private var updates: Task<Void, Never>?
    
    init() {
        updates = Task {
            for await update in StoreKit.Transaction.updates {
                if let transaction = try? update.payloadValue {
                    await fetchActiveTransactions()
                    await transaction.finish()
                }
            }
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    func showPaywall() {
        paywall = true
    }
    
    func fetchProducts() async {
        do {
            let productIdentifiers = ["default_monthly_subscription"]
            products = try await Product.products(for: productIdentifiers)
        } catch {
            print("Something went wrong \(error)")
            products = []
        }
    }
    
    func buyProduct(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case let .success(.verified(transaction)):
                // Successful purhcase
                await transaction.finish()
                await fetchActiveTransactions()
            case let .success(.unverified(_, error)):
                // Successful purchase but transaction/receipt can't be verified
                // Could be a jailbroken phone
                print("Unverified purchase. Might be jailbroken. Error: \(error)")
                break
            case .pending:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                break
            case .userCancelled:
                // Canceled
                print("User Cancelled!")
                break
            @unknown default:
                print("Failed to purchase the product!")
                break
            }
        } catch {
            print("Failed to purchase the product!")
        }
    }
    
    func fetchActiveTransactions() async {
        var activeTransactions: Set<Transaction> = []
        
        for await entitlement in Transaction.currentEntitlements {
            if let transaction = try? entitlement.payloadValue {
                activeTransactions.insert(transaction)
            }
        }
        
        self.activeTransactions = activeTransactions
        if !activeTransactions.isEmpty && paywall {
            paywall = false
        }
    }
    
    func hasProSubscription() -> Bool {
        !activeTransactions.isEmpty
    }
    
}
