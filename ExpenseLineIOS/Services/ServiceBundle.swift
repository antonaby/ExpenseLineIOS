//
//  ServiceBundle.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 29.03.24.
//

import Foundation
import Swinject

class DatabaseManagerBundle: Assembly {
    
    func assemble(container: Swinject.Container) {
        container.register(DatabaseManager.self) { _ in
            DatabaseManager(inMemory: false)
        }.inObjectScope(.container)
    }
    
}

#if DEBUG
class InMemoryDatabaseManagerBundle: Assembly {
    
    func assemble(container: Swinject.Container) {
        container.register(DatabaseManager.self) { _ in
            DatabaseManager(inMemory: true)
        }.inObjectScope(.container)
    }
    
}
#endif

class ServiceBundle: Assembly {
    
    func assemble(container: Swinject.Container) {
        container.register(ExpensesService.self) { resolver in
            ExpensesService(dm: resolver.resolve(DatabaseManager.self)!)
        }.inObjectScope(.container)
    }
    
}
