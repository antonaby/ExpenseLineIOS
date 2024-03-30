//
//  SpaceViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 30.03.24.
//

import Foundation


class SpaceViewModel: ObservableObject {
    
    private let entity: SpaceEntity
    private let es: ExpensesService
    
    init(_ entity: SpaceEntity, es: ExpensesService) {
        self.entity = entity
        self.es = es
    }
    
    func getName() -> String {
        entity.name ?? "Space"
    }
    
}
