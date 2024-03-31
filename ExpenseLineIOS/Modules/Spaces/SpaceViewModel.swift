//
//  SpaceViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 30.03.24.
//

import Foundation


class SpaceViewModel: ObservableObject {
    
    @Published var expenses: [ExpenseEntity]
    
    private let entity: SpaceEntity
    private let es: ExpensesService
    
    init(_ entity: SpaceEntity, es: ExpensesService) {
        self.entity = entity
        self.es = es
        self.expenses = []
    }
    
    func loadExpenses() {
        guard let id = entity.id else { return }
        
        do {
            expenses = try es.getExpensesForSpace(id)
        } catch {
            print("Unhandled error yet \(error)")
        }
    }
    
    func getName() -> String {
        entity.name ?? "Space"
    }
    
}
