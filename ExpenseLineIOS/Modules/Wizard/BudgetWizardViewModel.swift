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
    
    @Published var isFormValid: Bool = false
    @Published var selectedCategory: PlanCategoryEntity?
    
    var budget: BudgetEntity
    var editMode: Bool
    
    private var op: CategoryActionOperation = .none
    private let budgetService: BudgetService
    private let dataService: DataService
    private let analyticsService: AnalyticsService
    private let notificationService: NotificationService
    private var cancellables = Set<AnyCancellable>()
    private var categoriesToDelete: [PlanCategoryEntity] = []
    
    var formatters: FormattersHolder
    
    init(_ budget: BudgetEntity, budgetService: BudgetService, dataService: DataService,
         notificationService: NotificationService, analyticsService: AnalyticsService) {
        self.budget = budget
        self.editMode = !budget.isNew
        self.budgetService = budgetService
        self.dataService = dataService
        self.notificationService = notificationService
        self.analyticsService = analyticsService
        
        self.name = budget.name ?? ""
        let currency = dataService.getCurrencySymbolOrDefault(budget.currencyValue)
        self.currency = currency
        self.formatters = FormattersHolder(locale: currency.locale)
        
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
        let categories = budget.categoriesForType(types, skipUnnamed: true)
        let deletedCategoryIds = categoriesToDelete.map { $0.id }
        return categories.filter { !deletedCategoryIds.contains($0.id) }
    }
    
    func selectCategory(_ category: PlanCategoryEntity) {
        op = .update
        selectedCategory = category
    }
    
    func newCategory(_ type: CategoryType) {
        let category = budgetService.newCategoryEntity(budget)
        category.typeValue = type
        category.isNew = true
        op = .create
        selectedCategory = category
    }
    
    func updateCategory(_ category: PlanCategoryEntity) {
        selectedCategory = nil
        op = .none
    }
    
    func deleteCategory(_ category: PlanCategoryEntity) {
        selectedCategory = nil
        categoriesToDelete.append(category)
        
        op = .none
    }
    
    func dismissCategory(_ category: PlanCategoryEntity) {
        selectedCategory = nil
        if op == .create {
            budgetService.deleteCategoryWithNotifications(category, budget: budget)
        }
        
        op = .none
    }
    
    func isPageValid(_ page: WizzardPage) -> Bool {
        switch page {
        case .base:
            return isFormValid
        case .income:
            return budgetHasIncome()
        case .outcomeFixed:
            return true
        case .outcomeFlexible:
            return isBudgetValid()
        }
    }
    
    func isBudgetValid() -> Bool {
        return isFormValid && budgetHasIncome()
    }
    
    private func budgetHasIncome() -> Bool {
        budget.totalAmountForCategoryType(.income) > 0
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
        
        do {
            if !categoriesToDelete.isEmpty {
                for category in categoriesToDelete {
                    budgetService.deleteCategoryWithNotifications(category, budget: budget)
                }
            }
            
            try budgetService.save()
        } catch {
            logErrorEvent(error)
            print("Something went wrong \(error)")
        }
    }
    
    func rollback() {
        budgetService.rollback()
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
    private func logErrorEvent(_ error: Error) {
        analyticsService.logError(place: "budget_wizard", error: error)
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
