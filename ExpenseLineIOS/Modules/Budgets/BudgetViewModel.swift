//
//  HomeViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation
import Combine

enum BudgetViewPage: Hashable {
    case overview
    case categories
    case transactions
    case stats
}

enum DataUpdateType: Hashable {
    case budget
    case period
    case transaction
}

class BudgetViewModel: ObservableObject {
    
    @Published var currenPage: BudgetViewPage
    
    @Published var budget: BudgetEntity
    @Published var period: PeriodEntity
    
    var dataUpdateSubject = PassthroughSubject<DataUpdateType, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    var currency: CurrencySymbol
    var formatters: FormattersHolder
    
    private let budgetService: BudgetService
    private let dataService: DataService
    private let analyticsService: AnalyticsService
    
    var totalPlannedIncome: Decimal {
        get {
            totalPlannedIncomeCalculated
        }
    }
    
    private var totalPlannedIncomeCalculated: Decimal
    
    init(budget: BudgetEntity, period: PeriodEntity, page: BudgetViewPage = .overview, 
         budgetService: BudgetService, dataService: DataService, analyticsService: AnalyticsService) {
        self.budget = budget
        self.period = period
        self.currenPage = page
        self.budgetService = budgetService
        self.dataService = dataService
        self.analyticsService = analyticsService
        self.currency = dataService.getCurrencySymbolOrDefault(budget.currencyValue)
        self.totalPlannedIncomeCalculated = budget.totalAmountForCategoryType(.income)
        self.formatters = FormattersHolder(locale: currency.locale)
    }
    
    func reloadBudget() {
        do {
            if let budgetId = budget.id, let loadedBudget = try budgetService.getBudgetById(budgetId) {
                budget = loadedBudget
                currency = dataService.getCurrencySymbolOrDefault(budget.currencyValue)
                totalPlannedIncomeCalculated = budget.totalAmountForCategoryType(.income)
                formatters = FormattersHolder(locale: currency.locale)
                subscribe()
            }
        } catch {
            logErrorEvent(error)
            print("Something went wrong \(error)")
        }
    }
    
    private func subscribe() {
        $budget.sink { [weak self] budget in
            self?.dataUpdateSubject.send(.budget)
        }
        .store(in: &cancellables)
        $period.sink { [weak self] period in
            self?.dataUpdateSubject.send(.period)
        }
        .store(in: &cancellables)
    }
    
    func sendTransactionUpdated() {
        dataUpdateSubject.send(.transaction)
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
    private func logErrorEvent(_ error: Error) {
        analyticsService.logError(place: "budget", error: error)
    }
    
}
