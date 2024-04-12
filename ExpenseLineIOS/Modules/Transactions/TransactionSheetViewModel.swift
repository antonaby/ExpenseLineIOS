//
//  CreateTransactionSheetViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 12.04.24.
//

import Foundation
import Combine

struct CategoryName: Identifiable {
    
    var id: UUID
    var name: String
    var iconName: String
    
}

class TransactionSheetViewModel: ObservableObject {
    
    @Published var name: String
    @Published var amount: Double
    @Published var isValid: Bool
    @Published var category: CategoryName?
    
    private let budget: BudgetEntity
    private let budgetService: BudgetService
    
    // TODO: cancel all
    private var cancellables = Set<AnyCancellable>()
    private var categoryEntities: [PlanCategoryEntity] = []
    
    init(budget: BudgetEntity, budgetService: BudgetService) {
        self.budget = budget
        self.budgetService = budgetService
        
        self.name = ""
        self.amount = 0
        self.isValid = false
        self.category = nil
        
        isFormValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFormValid in
                guard let self = self else { return }
                self.isValid = isFormValid
            }
            .store(in: &cancellables)
    }
    
    func getCetegories() -> [CategoryName] {
        guard let budgetId = budget.id else { return [] }
        
        do {
            categoryEntities = try budgetService.getCategoriesOfBudget(budgetId)
            return categoryEntities
                .map {
                    CategoryName(
                        id: $0.id ?? UUID(),
                        name: $0.name ?? "Unknown",
                        iconName: $0.iconName ?? "Unknown"
                    )
                }
        } catch {
            // TODO: show error
            return []
        }
    }
    
    func createTransaction() {
        let categoryEntity = categoryEntities.filter {
            if let entityId = $0.id, let categoryId = category?.id {
                return entityId == categoryId
            }
            
            return false
        }.first
        
        if let entity = categoryEntity {
            do {
                try budgetService.createTransaction(
                    Transaction(id: UUID(), name: name, amount: amount, createdAt: Date()),
                    category: entity,
                    budget: budget
                )
            } catch {
                // TODO: show error
                print("Error: \(error)")
            }
        }
    }
    
}

private extension TransactionSheetViewModel {
    
    var isNameValid: AnyPublisher<Bool, Never> {
        $name
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { name in
                name.count > 0
            }
            .eraseToAnyPublisher()
    }
    
    var isCategoryVaild: AnyPublisher<Bool, Never> {
        $category
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { category in
                category != nil
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
    
    var isFormValid: AnyPublisher<Bool, Never> {
        Publishers
            .CombineLatest3(isNameValid, isCategoryVaild, isAmountValid)
            .map { isNameValid, isCategoryVaild, isAmountValid in
                isNameValid && isCategoryVaild && isAmountValid
            }
            .eraseToAnyPublisher()
    }
    
}
