//
//  BudgetWizardViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.04.24.
//

import Foundation
import Combine

enum CategoryActionOperation {
    case none
    case create
    case update
    case delete
}

class BudgetWizardViewModel: ObservableObject {
    
    @Published var name: String
    @Published var currency: CurrencySymbol
    @Published var periodStartsAt: Date
    @Published var dailyReminderAt: Date
    
    @Published var isFormValid: Bool = false
    @Published var selectedCategory: PlanCategoryEntity?
    
    var currencyFormatter: NumberFormatter
    var percnetFormatter: NumberFormatter
    
    private var op: CategoryActionOperation = .none
    private var budget: BudgetEntity
    private var budgetService: BudgetService
    private var dataService: DataService
    private var cancellables = Set<AnyCancellable>()
    
    init(_ budget: BudgetEntity, budgetService: BudgetService, dataService: DataService) {
        self.budget = budget
        self.budgetService = budgetService
        self.dataService = dataService
        
        self.name = budget.name ?? ""
        let currencyLocaleId = budget.currency ?? Locale.current.identifier
        let currency = dataService.getCurrensySymbolById(currencyLocaleId) ?? dataService.getDefaultCurrencySymbol()
        self.currency = currency
        self.dailyReminderAt = budget.dailyRemainderAt ?? Date()
        self.periodStartsAt = budget.periodStartsAt ?? Date().firstDayOfMonth()
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: currency.id)
        currencyFormatter.minimumFractionDigits = 0
        currencyFormatter.maximumFractionDigits = 2
        self.currencyFormatter = currencyFormatter
        
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale(identifier: currency.id)
        percentFormatter.minimumFractionDigits = 0
        percentFormatter.maximumFractionDigits = 2
        self.percnetFormatter = percentFormatter
        
        isValid.sink { [weak self]  isValid in
            guard let self = self else { return }
            self.isFormValid = isValid
        }
        .store(in: &cancellables)
        
        $currency.sink { [weak self] currency in
            self?.currencyFormatter.locale = Locale(identifier: currency.id)
        }
        .store(in: &cancellables)
    }
    
    func categoriesForType(_ types: [CategoryType]) -> [PlanCategoryEntity] {
        let categories = budget.categories?.allObjects as? [PlanCategoryEntity] ?? []
        return categories
            .filter { !$0.nameValue.isEmpty && types.contains($0.typeValue) }
            .sorted(by: { $0.nameValue < $1.nameValue })
    }
    
    func selectCategory(_ category: PlanCategoryEntity) {
        op = .update
        selectedCategory = category
    }
    
    func newCategory(_ types: [CategoryType]) {
        var category: PlanCategoryEntity
        
        if types.contains(.income) {
            let entity = budgetService.newCategoryEntity(budget)
            entity.typeValue = .income
            category = entity
        } else {
            let entity = budgetService.newCategoryEntity(budget)
            entity.typeValue = .outcomeFixed
            category = entity
        }
        
        op = .create
        selectedCategory = category
    }
    
    func updateCategory(_ category: PlanCategoryEntity) {
        selectedCategory = nil
        op = .none
    }
    
    func deleteCategory(_ category: PlanCategoryEntity) {
        selectedCategory = nil
        budgetService.deleteCategory(category, budget: budget)
        
        op = .none
    }
    
    func dismissCategory(_ category: PlanCategoryEntity) {
        selectedCategory = nil
        if op == .create {
            budgetService.deleteCategory(category, budget: budget)
        }
        
        op = .none
    }
    
    func getTotalIncome() -> String {
        return currencyFormatter.string(from: totalAmountForCategory(.income) as NSDecimalNumber) ?? "0"
    }
    
    func getTotalOutcome() -> String {
        let totalFixedOutcome = totalAmountForCategory(.outcomeFixed)
        let totalPercentOutcome = totalAmountForCategory(.income) * totalPercentFractionForCategory(.outcomePercent)
        let totalOutcome = totalFixedOutcome + totalPercentOutcome
        
        return currencyFormatter.string(from: totalOutcome as NSDecimalNumber) ?? "0"
    }
    
    private func totalAmountForCategory(_ type: CategoryType) -> Decimal {
        let incomeCategories = categoriesForType([type])
        return incomeCategories.reduce(0) { $0 + $1.amountDecimal }
    }
    
    private func totalPercentFractionForCategory(_ type: CategoryType) -> Decimal {
        let incomeCategories = categoriesForType([type])
        return incomeCategories.reduce(0) { $0 + ($1.percentValue as Decimal) }
    }
    
    func save() {
        budget.name = name
        budget.currency = currency.id
        budget.dailyRemainderAt = dailyReminderAt
        budget.periodStartsAt = periodStartsAt
        
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
    
}

extension BudgetWizardViewModel {
    
    var isNameValid: AnyPublisher<Bool, Never> {
        $name.debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { name in
                name.count > 0
            }
            .eraseToAnyPublisher()
    }
    
    var isCurrencyValid: AnyPublisher<Bool, Never> {
        $currency.debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { currency in
                !currency.id.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    var isValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isNameValid, isCurrencyValid)
            .map { isNameValid, isCurrencyValid in
                isNameValid && isCurrencyValid
            }
            .eraseToAnyPublisher()
    }
    
}
