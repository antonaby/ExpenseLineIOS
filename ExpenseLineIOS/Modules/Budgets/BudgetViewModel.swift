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
    
    private let budgetService: BudgetService
    private let dataService: DataService
    
    var totalPlannedIncome: Decimal {
        get {
            totalPlannedIncomeCalculated
        }
    }
    
    private var totalPlannedIncomeCalculated: Decimal
    
    init(budget: BudgetEntity, period: PeriodEntity, page: BudgetViewPage = .overview, budgetService: BudgetService, dataService: DataService) {
        self.budget = budget
        self.period = period
        self.currenPage = page
        self.budgetService = budgetService
        self.dataService = dataService
        self.currency = dataService.getCurrencySymbolOrDefault(budget.currencyValue)
        self.totalPlannedIncomeCalculated = budget.totalAmountForCategoryType(.income)
        
        $budget.sink { [weak self] budget in
            self?.dataUpdateSubject.send(.budget)
        }
        .store(in: &cancellables)
        $period.sink { [weak self] period in
            self?.dataUpdateSubject.send(.period)
        }
        .store(in: &cancellables)
    }
    
    func reloadBudget() {
        do {
            if let budgetId = budget.id, let loadedBudget = try budgetService.getBudgetById(budgetId) {
                budget = loadedBudget
                currency = dataService.getCurrencySymbolOrDefault(budget.currencyValue)
                totalPlannedIncomeCalculated = budget.totalAmountForCategoryType(.income)
            }
        } catch {
            // TODO: handle exception
            print("Something went wrong \(error)")
        }
    }
    
    func sendTransactionUpdated() {
        dataUpdateSubject.send(.transaction)
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
}
