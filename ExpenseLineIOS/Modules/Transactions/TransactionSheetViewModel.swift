//
//  CreateTransactionSheetViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 12.04.24.
//

import Foundation
import Combine

class TransactionSheetViewModel: ObservableObject {
    
    @Published var name: String
    @Published var amount: String
    @Published var isValid: Bool
    @Published var category: PlanCategoryEntity?
    @Published var date: Date
    @Published var categories: [PlanCategoryEntity]
    
    var transaction: TransactionEntity
    
    let currency: CurrencySymbol
    let locale: Locale
    
    private let budget: BudgetEntity
    private let budgetService: BudgetService
    
    // TODO: cancel all
    private var cancellables = Set<AnyCancellable>()
    private var categoryEntities: [PlanCategoryEntity] = []
    
    var currencySymbol: String {
        return locale.currencySymbolOrDefault(EditPlanCategorySheetViewModel.defaultSymbol)
    }
    
    var separator: String {
        locale.decimalSepapatorOrDefault(EditPlanCategorySheetViewModel.defaultSeparator)
    }
    
    var isSymbolTrailing: Bool {
        locale.isCurrencySymbolTrailing()
    }
    
    init(budget: BudgetEntity, currency: CurrencySymbol, budgetService: BudgetService) {
        self.budget = budget
        self.budgetService = budgetService
        self.currency = currency
        self.locale = currency.locale
        self.transaction = budgetService.newTransactionEntity(budget)
        
        self.name = ""
        self.amount = ""
        self.isValid = false
        self.category = nil
        self.date = Date()
        self.categories = []
        
        isFormValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFormValid in
                guard let self = self else { return }
                self.isValid = isFormValid
            }
            .store(in: &cancellables)
    }
    
    func loadCetegories() {
        do {
            categories = try budgetService.getCategoriesOfBudget(budget, types: [.outcomeFixed, .outcomePercent])
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
        }
    }
    
    func save() {
        transaction.name = name
        transaction.amountDecimal = convertToDecimalNumber(amount, symbol: currencySymbol)
        transaction.category = category
        transaction.budget = budget
        transaction.createdAt = date
        
        do {
            try budgetService.save()
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
        }
    }
    
    func rollback() {
        budgetService.rollback()
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
    private func convertToDecimalNumber(_ value: String, symbol: String) -> Decimal {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = separator
        let cleanAmount = value.replacingOccurrences(of: symbol, with: "")
        let result = formatter.number(from: cleanAmount)?.decimalValue ?? 0
        
        return result
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
                !amount.isEmpty
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
