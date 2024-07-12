//
//  ExpenseLineIOSApp.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
    FirebaseApp.configure()
    return true
  }
    
}


@main
struct ExpenseLineIOSApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var serviceBundle: ServiceBundle
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var subscriptionManager: SubscriptionManager
    
    init() {
        var bundle = ServiceBundle()
        self.serviceBundle = bundle
        self._subscriptionManager = StateObject(wrappedValue: SubscriptionManager(analyticsService: bundle.analyticsService))
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(appState: AppState(bundle: serviceBundle))
                .environmentObject(subscriptionManager)
                .serviceBundle(serviceBundle)
                .task(id: scenePhase) {
                    if scenePhase == .active {
                        await subscriptionManager.fetchActiveTransactions()
                    }
                }
        }
    }
}
