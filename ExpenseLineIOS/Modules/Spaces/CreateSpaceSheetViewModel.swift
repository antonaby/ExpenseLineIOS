//
//  CreateSpaceSheetViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation
import Combine


class CreateSpaceSheetViewModel: ObservableObject {
    
    @Published var name: String
    @Published var isValid: Bool
    
    let budget: BudgetEntity
    
    private let es: ExpensesService
    // TODO: cancel all
    private var cancellables = Set<AnyCancellable>()
    
    init(budget: BudgetEntity, es: ExpensesService) {
        self.budget = budget
        self.es = es
        
        self.name = ""
        self.isValid = false
        
        isSpaceNameValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                guard let self = self else { return }
                self.isValid = isValid
            }
            .store(in: &cancellables)
    }
    
    func createSpace() {
        es.addSpace(Space(id: UUID(), name: name, iconName: "No"), budget: budget)
    }
    
}

private extension CreateSpaceSheetViewModel {
    
    var isSpaceNameValid: AnyPublisher<Bool, Never> {
        $name
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { name in
                name.count > 0
            }
            .eraseToAnyPublisher()
    }
    
}
