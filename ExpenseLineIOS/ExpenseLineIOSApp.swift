//
//  ExpenseLineIOSApp.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI

@main
struct ExpenseLineIOSApp: App {
    
    private let resolver = DependencyResolver(assemblies: DatabaseManagerBundle(), ServiceBundle(), ModulesBundle())
    
    var body: some Scene {
        WindowGroup {
            HomeView(vm: resolver.homeViewModel(), path: NavigationPath())
                .environmentObject(resolver)
        }
    }
}
