//
//  BudgetWizardViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.04.24.
//

import Foundation
import Combine

enum WizzardPage: Int, Hashable {
    case base = 0
    case income
    case fixed
    case dynamic
    case summary
}

enum CategoryActionOperation {
    case none
    case create
    case update
    case delete
}

class BudgetWizardViewModel: ObservableObject {
    
    @Published var name: String
    @Published var currency: String
    @Published var type: PlanType
    @Published var periodStartsAt: Date
    @Published var dailyReminderAt: Date
    
    @Published var isFormValid: Bool = false
    @Published var selectedCategory: PlanCategoryEntity?
    
    private var op: CategoryActionOperation = .none
    private var budget: BudgetEntity
    private var budgetService: BudgetService
    private var cancellables = Set<AnyCancellable>()
    
    init(_ budget: BudgetEntity, budgetService: BudgetService) {
        self.budget = budget
        self.budgetService = budgetService
        
        self.name = budget.name ?? "My Budget"
        self.currency = budget.currency ?? "EUR"
        self.type = budget.planTypeValue
        self.dailyReminderAt = budget.dailyRemainderAt ?? Date()
        self.periodStartsAt = budget.periodStartsAt ?? BudgetWizardViewModel.getFirstDayOfPeriod()
        
        isValid.sink { [weak self]  isValid in
            guard let self = self else { return }
            self.isFormValid = isValid
        }
        .store(in: &cancellables)
    }
    
    func categoriesForType(_ type: PlanCategoryType) -> [PlanCategoryEntity] {
        let categories = budget.categories?.allObjects as? [PlanCategoryEntity] ?? []
        return categories.filter { $0.typeValue == type }
    }
    
    func selectCategory(_ category: PlanCategoryEntity) {
        op = .update
        selectedCategory = category
    }
    
    func newCategory(_ page: WizzardPage) {
        var category: PlanCategoryEntity
        
        // TODO: generate from data
        switch page {
        case .income:
            let entity = budgetService.newCategoryEntity(budget)
            entity.typeValue = .income
            entity.name = "My Income"
            entity.iconName = "case"
            category = entity
        case .fixed:
            let entity = budgetService.newCategoryEntity(budget)
            entity.typeValue = .outcomeFixed
            entity.name = "My Fixed Outcome"
            entity.iconName = "case"
            category = entity
        case .dynamic:
            let entity = budgetService.newCategoryEntity(budget)
            entity.typeValue = .outcomePercent
            entity.name = "My daily spending"
            entity.iconName = "car"
            category = entity
        default:
            return
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
    
    func getCurrencies() -> [String] {
        return ["USD", "EUR", "RUB", "AMD", "INR"] // TODO: get currencies from DB
    }
    
    func getDateRange() -> ClosedRange<Date> {
        let periodComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        let firstDay = Calendar.current.date(from: periodComponents)!
        
        return firstDay ... Date()
    }
    
    // TODO: cancel all
    func cancelAll() {
        for c in cancellables {
            c.cancel()
        }
    }
    
    func save() {
        budget.name = name
        budget.currency = currency
        budget.planTypeValue = type
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
    
    // TODO: move to extensions
    private static func getFirstDayOfPeriod() -> Date {
        let periodComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        return Calendar.current.date(from: periodComponents)!
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
                currency.count == 3
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
    
    
    /*@Published var budget: BudgetEntity
    
    private let budgetService: BudgetService
    private let dataService: DataService
    
    // TODO: Review
    @Published var name: String
    @Published var currency: String
    @Published var type: PlanType
    @Published var dailyReminder: Date
    
    @Published var incomeSources: [PlanCategory]
    @Published var selectedIncomeSource: PlanCategory
    @Published var incomeSourceOp: DataEditOp
    
    @Published var fixedOutcomes: [PlanCategory]
    @Published var selectedFixedOutcome: PlanCategory
    @Published var fixedOutcomeOp: DataEditOp
    
    @Published var dailyOutcomes: [PlanCategory]
    @Published var selectedDailyOutcome: PlanCategory
    @Published var dailyOutcomeOp: DataEditOp
    
    @Published var periodStartsAt: Date
    
    
    
    init(budget: BudgetEntity, budgetService: BudgetService, dataService: DataService) {
        self.budget = budget
        self.budgetService = budgetService
        self.dataService = dataService
        
        
        
        // TODO: review
        self.name = "My Budget"
        self.currency = "USD"
        self.type = .mountly
        
        self.incomeSources = [
            PlanCategory(id: UUID(), name: "Salary", amount: 0, percent: 0, iconName: "case", type: .income, createdAt: Date())
        ]
        self.selectedIncomeSource = PlanCategory(id: UUID(), name: "My Income", amount: 0, percent: 0, iconName: "case", type: .income, createdAt: Date())
        self.incomeSourceOp = .none
        
        self.fixedOutcomes = [
            PlanCategory(id: UUID(), name: "Rent", amount: 0, percent: 0, iconName: "house", type: .outcomeFixed, createdAt: Date()),
            PlanCategory(id: UUID(), name: "Internet", amount: 0, percent: 0, iconName: "globe", type: .outcomeFixed, createdAt: Date()),
            PlanCategory(id: UUID(), name: "Phone", amount: 0, percent: 0, iconName: "phone", type: .outcomeFixed, createdAt: Date())
        ]
        self.selectedFixedOutcome = PlanCategory(id: UUID(), name: "My fixed outcome", amount: 0, percent: 0, iconName: "case", type: .outcomeFixed, createdAt: Date())
        self.fixedOutcomeOp = .none
        
        self.dailyOutcomes = [
            PlanCategory(id: UUID(), name: "Groceries", amount: 0, percent: 0, iconName: "cart", type: .outcomePercent, createdAt: Date()),
            PlanCategory(id: UUID(), name: "Coffee", amount: 0, percent: 0, iconName: "cup.and.saucer", type: .outcomePercent, createdAt: Date())
        ]
        self.selectedDailyOutcome = PlanCategory(id: UUID(), name: "My daily expense", amount: 0, percent: 0, iconName: "car", type: .outcomePercent, createdAt: Date())
        self.dailyOutcomeOp = .none
        
        let components = DateComponents(hour: 20, minute: 0)
        self.dailyReminder = Calendar.current.date(from: components) ?? Date()
        
        let periodComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        self.periodStartsAt = Calendar.current.date(from: periodComponents)!
    }
    
    func getTotalIncome() -> Double {
        return incomeSources.reduce(0) { $0 + $1.amount }
    }
    
    func getTotalFixedOutcome() -> Double {
        return fixedOutcomes.reduce(0) { $0 + $1.amount }
    }
    
    func getTotalDailyOutcome() -> Double {
        let budget = getTotalIncome()
        return dailyOutcomes.reduce(0) { $0 + budget * $1.percent }
    }
    
    func getAmountForDailyCatedory(_ category: PlanCategory) -> Double {
        return getTotalIncome() * category.percent
    }
    
    func getRemainingBudget() -> Double {
        return getTotalIncome() - getTotalFixedOutcome() - getTotalDailyOutcome()
    }
    
    func remainingAsString() -> String {
        let income = incomeSources.reduce(0) { $0 + $1.amount }
        let outcome = fixedOutcomes.reduce(0) { $0 + $1.amount }
        
        return String(format: "%.2f", income - outcome)
    }
    
    // TODO: add all currencies
    func getCurrencies() -> [String] {
        ["USD", "EUR", "AMD", "RUB"]
    }
    
    func createBudget() {
        let budget = Budget(id: UUID(), name: name, currency: currency, type: type)
        
        var components = DateComponents()
        components.month = 1
        components.second = -1
        let periodEndsAt = Calendar.current.date(byAdding: components, to: periodStartsAt)!
        let period = Period(id: UUID(), startsAt: periodStartsAt, endsAt: periodEndsAt)
        
        var categories: [PlanCategory] = []
        categories.append(contentsOf: incomeSources)
        categories.append(contentsOf: fixedOutcomes)
        categories.append(contentsOf: dailyOutcomes)
        
        do {
            try budgetService.createBudget(budget: budget, period: period, categories: categories)
        } catch {
            // TODO: show correct error
            print("Error \(error)")
        }
    }
    
    func selectDailyOutcome(_ outcome: PlanCategory, op: DataEditOp) {
        selectedDailyOutcome = outcome
        dailyOutcomeOp = op
    }
    
    func newDailyOutcome() {
        selectedDailyOutcome =
        dailyOutcomeOp = .create
    }
    
    func selectFixedOutcome(_ outcome: PlanCategory, op: DataEditOp) {
        selectedFixedOutcome = outcome
        fixedOutcomeOp = op
    }
    
    func newFixedOutcome() {
        selectedFixedOutcome =
        fixedOutcomeOp = .create
    }
    
    func selectIncomeSource(_ source: PlanCategory, op: DataEditOp) {
        selectedIncomeSource = source
        incomeSourceOp = op
    }
    
    func newIncomeSource() {
        selectedIncomeSource = PlanCategory(id: UUID(), name: "My Income", amount: 0, percent: 0, iconName: "case", type: .income, createdAt: Date())
        incomeSourceOp = .create
    }
    
    func performEditOps() {
        switch incomeSourceOp {
        case .create:
            incomeSources.append(selectedIncomeSource)
        case .edit:
            updateIncomeSource()
        case .delete:
            deleteIncomeSource()
        case .none: 
            break
        }
        
        incomeSourceOp = .none
        
        switch fixedOutcomeOp {
        case .create:
            fixedOutcomes.append(selectedFixedOutcome)
        case .edit:
            updateFixedOutcome()
        case .delete:
            deleteFixedOutcome()
        case .none:
            break
        }
        
        fixedOutcomeOp = .none
        
        switch dailyOutcomeOp {
        case .create:
            dailyOutcomes.append(selectedDailyOutcome)
        case .edit:
            updateDailyOutcome()
        case .delete:
            deleteDailyOutcome()
        case .none:
            break
        }
        
        dailyOutcomeOp = .none
    }
    
    func updateIncomeSource() {
        if let source = incomeSources.enumerated().filter({ $0.element.id == selectedIncomeSource.id }).first {
            incomeSources[source.offset] = selectedIncomeSource
        }
    }
    
    func deleteIncomeSource() {
        if let source = incomeSources.enumerated().filter({ $0.element.id == selectedIncomeSource.id }).first {
            incomeSources.remove(at: source.offset)
        }
    }
    
    func updateFixedOutcome() {
        if let source = fixedOutcomes.enumerated().filter({ $0.element.id == selectedFixedOutcome.id }).first {
            fixedOutcomes[source.offset] = selectedFixedOutcome
        }
    }
    
    func deleteFixedOutcome() {
        if let source = fixedOutcomes.enumerated().filter({ $0.element.id == selectedFixedOutcome.id }).first {
            fixedOutcomes.remove(at: source.offset)
        }
    }
    
    func updateDailyOutcome() {
        if let source = dailyOutcomes.enumerated().filter({ $0.element.id == selectedDailyOutcome.id }).first {
            dailyOutcomes[source.offset] = selectedDailyOutcome
        }
    }
    
    func deleteDailyOutcome() {
        if let source = dailyOutcomes.enumerated().filter({ $0.element.id == selectedDailyOutcome.id }).first {
            dailyOutcomes.remove(at: source.offset)
        }
    }
    
    func getDateRange() -> ClosedRange<Date> {
        let periodComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        let firstDay = Calendar.current.date(from: periodComponents)!
        
        return firstDay ... Date()
    }
     */
    


