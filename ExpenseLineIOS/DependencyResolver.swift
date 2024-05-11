//
//  DependencyResolver.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 29.03.24.
//

import Foundation
import Swinject

enum DependencyResolverError: Error {
    case ResolveError(msg: String, reason: Error?)
}

class DependencyResolver: ObservableObject {
    
    static let shared = DependencyResolver(assemblies: DatabaseManagerBundle(), ServiceBundle())
    
    private let assembler: Assembler
        
    var resolver: Resolver { self.assembler.resolver }
    
    init(assemblies: Assembly...) {
        self.assembler = Assembler(assemblies)
    }
    
}

extension DependencyResolver {
    
    func databaseManager() -> DatabaseManager {
        resolver.resolve(DatabaseManager.self)!
    }
    
    func budgetService() -> BudgetService {
        resolver.resolve(BudgetService.self)!
    }
    
    func dataService() -> DataService {
        resolver.resolve(DataService.self)!
    }
    
    
}

#if DEBUG
extension DependencyResolver {
    
    public static let preview = DependencyResolver(assemblies: InMemoryDatabaseManagerBundle(), ServiceBundle())
    
}
#endif
