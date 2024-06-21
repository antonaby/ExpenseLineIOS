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
    @Published var dailyReminderEnabled: Bool
    @Published var dailyReminderAt: Date
    
    @Published var isFormValid: Bool = false
    @Published var selectedCategory: PlanCategoryEntity?
    
    var budget: BudgetEntity
    
    private var op: CategoryActionOperation = .none
    private var budgetService: BudgetService
    private var dataService: DataService
    private var notificationService: NotificationService
    private var cancellables = Set<AnyCancellable>()
    
    var formatters: FormattersHolder
    
    init(_ budget: BudgetEntity, budgetService: BudgetService, dataService: DataService, notificationService: NotificationService) {
        self.budget = budget
        self.budgetService = budgetService
        self.dataService = dataService
        self.notificationService = notificationService
        
        self.name = budget.name ?? ""
        let currency = dataService.getCurrencySymbolOrDefault(budget.currencyValue)
        self.currency = currency
        self.formatters = FormattersHolder(locale: currency.locale)
        self.dailyReminderEnabled = budget.dailyRemainderAt != nil
        self.dailyReminderAt = budget.dailyRemainderAt ?? Date().currentDateAt(at: 20)
        
        isValid.sink { [weak self]  isValid in
            guard let self = self else { return }
            self.isFormValid = isValid
        }
        .store(in: &cancellables)
        
        $currency.sink { [weak self] currency in
            self?.formatters = FormattersHolder(locale: currency.locale)
        }
        .store(in: &cancellables)
    }
    
    func categoriesForType(_ types: [CategoryType]) -> [PlanCategoryEntity] {
        budget.categoriesForType(types, skipUnnamed: true)
    }
    
    func selectCategory(_ category: PlanCategoryEntity) {
        op = .update
        selectedCategory = category
    }
    
    func newCategory(_ type: CategoryType) {
        let category = budgetService.newCategoryEntity(budget)
        category.typeValue = type
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
    
    func calculateTotalIncome() -> Decimal {
        budget.totalAmountForCategoryType(.income)
    }
    
    func getTotalIncome() -> String {
        return formatters.formatAmount(budget.totalAmountForCategoryType(.income))
    }
    
    func getTotalOutcome() -> String {
        let totalFixedOutcome = budget.totalAmountForCategoryType(.outcomeFixed)
        let totalPercentOutcome = budget.totalAmountForCategoryType(.income) * budget.totalPercentForCategoryType(.outcomePercent)
        let totalOutcome = totalFixedOutcome + totalPercentOutcome
        
        return formatters.formatAmount(totalOutcome)
    }
    
    func save() {
        budget.name = name
        budget.currency = currency.id
        if dailyReminderEnabled {
            budget.dailyRemainderAt = dailyReminderAt
        } else {
            budget.dailyRemainderAt = nil
        }
        
        do {
            try budgetService.save()
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
        }
        sheduleNotification()
    }
    
    func rollback() {
        budgetService.rollback()
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
    private func sheduleNotification() {
        guard let budgetId = budget.id else { return }
        
        if let dayliReminder = budget.dailyRemainderAt {
            notificationService.requestAuthorization()
            notificationService.scheduleDailyReminder(budgetId: budgetId, date: dayliReminder)
        } else {
            notificationService.cancelDailyReminder(budgetId: budgetId)
        }
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
