//
//  CreateBudgetSheetViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import Foundation
import Combine


class CreateBudgetSheetViewModel: ObservableObject {
    
    @Published var name: String
    @Published var currecny: String
    @Published var type: PlanType
    @Published var isValid: Bool
    
    private let es: ExpensesService
    
    // TODO: cancel all
    private var cancellables = Set<AnyCancellable>()
    
    init(es: ExpensesService) {
        self.es = es
        
        self.name = ""
        self.currecny = "USD"
        self.type = .mountly
        self.isValid = false
        
        isBudgetNameValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                guard let self = self else { return }
                self.isValid = isValid
            }
            .store(in: &cancellables)
    }
    
    func createBudget() {
        es.addBudget(Budget(id: UUID(), name: name, currency: currecny, type: type))
    }
    
    func getCurrencies() -> [String] {
        ["USD", "EUR", "RUB", "CHF", "AMD"]
    }
    
}

private extension CreateBudgetSheetViewModel {
    
    var isBudgetNameValid: AnyPublisher<Bool, Never> {
        $name
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { name in
                name.count > 0
            }
            .eraseToAnyPublisher()
    }
    
    
    
}
