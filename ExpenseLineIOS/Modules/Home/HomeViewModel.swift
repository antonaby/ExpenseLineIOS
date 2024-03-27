//
//  HomeViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation


class HomeViewModel: ObservableObject {
    
    @Published var spaces: [Space]
    @Published var totalAmount: Int
    
    init() {
        self.spaces = []
        self.totalAmount = 0
    }
    
    func loadSpaces() {
        do {
            spaces = try ExpensesService.shared.getSpaces()
        } catch {
            // TODO: show error
        }
    }
    
    func loadTotalAmount() {
        totalAmount = ExpensesService.shared.getTotalAmount()
    }
    
}
