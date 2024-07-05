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
    
    let serviceBundle = ServiceBundle()
    
    var body: some Scene {
        WindowGroup {
            MainView(appState: AppState(bundle: serviceBundle))
                .serviceBundle(serviceBundle)
        }
    }
}
