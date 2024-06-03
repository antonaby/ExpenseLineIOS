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
    
    private var currencyFormatter: NumberFormatter = NumberFormatter()
    private var percentFormatter: NumberFormatter = NumberFormatter()
    private var dateFormatter: DateFormatter = DateFormatter()
    
    private let budgetService: BudgetService
    private let dataService: DataService
    
    var totalPlannedIncome: Decimal {
        get {
            budget.totalAmountForCategoryType(.income)
        }
    }
    
    init(budget: BudgetEntity, period: PeriodEntity, page: BudgetViewPage = .overview, budgetService: BudgetService, dataService: DataService) {
        self.budget = budget
        self.period = period
        self.currenPage = page
        self.budgetService = budgetService
        self.dataService = dataService
        self.currency = dataService.getCurrencySymbolOrDefault(budget.currencyValue)
        createFormatters(locale: currency.locale)
        
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
                createFormatters(locale: currency.locale)
            }
        } catch {
            // TODO: handle exception
            print("Something went wrong \(error)")
        }
    }
    
    func sendTransactionUpdated() {
        dataUpdateSubject.send(.transaction)
    }
    
    func formatAmount(_ amount: Decimal) -> String {
        if let fomatted = currencyFormatter.string(from: amount as NSDecimalNumber) {
            return fomatted
        }
        
        print("Error, amount: \(amount) can't be formatted") // TODO: send error event
        return "?"
    }
    
    func formatPercent(_ percent: Decimal) -> String {
        if let fomatted = percentFormatter.string(from: percent as NSDecimalNumber) {
            return fomatted
        }
        
        print("Error, amount: \(percent) can't be formatted") // TODO: send error event
        return "?"
    }
    
    func formatDate(_ date: Date?) -> String {
        if let currentDate = date {
            return dateFormatter.string(from: currentDate)
        }
        
        return "?"
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
    private func createFormatters(locale: Locale) {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = locale
        currencyFormatter.minimumFractionDigits = 0
        currencyFormatter.maximumFractionDigits = 2
        self.currencyFormatter = currencyFormatter
        
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = locale
        percentFormatter.minimumFractionDigits = 0
        percentFormatter.maximumFractionDigits = 0
        self.percentFormatter = percentFormatter
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.setLocalizedDateFormatFromTemplate("MM-dd-yyyy HH:mm")
        self.dateFormatter = dateFormatter
    }
    
}
