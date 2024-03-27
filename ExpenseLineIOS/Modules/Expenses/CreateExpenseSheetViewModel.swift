//
//  CreateExpenseSheetViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 26.03.24.
//

import Foundation
import Combine


class CreateExpenseSheetViewModel: ObservableObject {
    
    @Published var name: String
    @Published var amount: Int
    @Published var isValid: Bool
    @Published var space: Space?
    
    // TODO: cancel all
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.name = ""
        self.amount = 0
        self.isValid = false
        self.space = nil
        
        isFormValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFormValid in
                guard let self = self else { return }
                self.isValid = isFormValid
            }
            .store(in: &cancellables)
    }
    
    // TODO: add currency
    func createExpense() {
        guard let space = self.space else { return }
        do {
            try ExpensesService.shared.addExpense(
                Expense(id: UUID(), spaceId: space.id, name: name, amount: amount, currency: "USD"))
        } catch {
            // TODO: show error
            print(error)
        }
    }
    
    func getSpaces() -> [Space] {
        do {
            return try ExpensesService.shared.getSpaces()
        } catch {
            // TODO: Show error instead
            return []
        }
    }
    
    func setSpace(_ space: Space) {
        self.space = space
    }
    
}

private extension CreateExpenseSheetViewModel {
    
    var isExpenseNameValid: AnyPublisher<Bool, Never> {
        $name
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { name in
                name.count > 0
            }
            .eraseToAnyPublisher()
    }
    
    var isAmountValid: AnyPublisher<Bool, Never> {
        $amount
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { amount in
                amount > 0
            }
            .eraseToAnyPublisher()
    }
    
    var isSpaceSelected: AnyPublisher<Bool, Never> {
        $space
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { space in
                space != nil
            }
            .eraseToAnyPublisher()
    }
    
    var isFormValid: AnyPublisher<Bool, Never> {
        Publishers
            .CombineLatest3(isExpenseNameValid, isAmountValid, isSpaceSelected)
            .map { isNameValid, isAmountValid, isSpaceSelected in
                isNameValid && isAmountValid && isSpaceSelected
            }
            .eraseToAnyPublisher()
    }
    
}
