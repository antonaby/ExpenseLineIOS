//
//  DependencyResolver.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 29.03.24.
//

import Foundation
import Swinject


class DependencyResolver: ObservableObject {
    
    private let assembler: Assembler
        
    var resolver: Resolver { self.assembler.resolver }
    
    init(assemblies: Assembly...) {
        self.assembler = Assembler(assemblies)
    }
    
}

#if DEBUG
extension DependencyResolver {
    
    public static let preview = DependencyResolver(assemblies: InMemoryDatabaseManagerBundle(), ServiceBundle(), ModulesBundle())
    
}
#endif
