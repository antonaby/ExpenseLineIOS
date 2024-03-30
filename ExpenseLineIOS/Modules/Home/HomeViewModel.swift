//
//  HomeViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation


class HomeViewModel: ObservableObject {
    
    @Published var bugget: BudgetEntity?
    @Published var spaces: [SpaceEntity]
    @Published var totalAmount: Int
    
    private let es: ExpensesService
    
    init(es: ExpensesService) {
        self.es = es
        
        self.spaces = []
        self.totalAmount = 0
    }
    
    func loadSpaces() {
        do {
            spaces = try es.getSpaces()
        } catch {
            // TODO: show error
        }
    }
    
    func loadTotalAmount() {
        totalAmount = es.getTotalAmount()
    }
    
}
