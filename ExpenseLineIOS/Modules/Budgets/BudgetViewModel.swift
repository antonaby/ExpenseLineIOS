//
//  HomeViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation


class BudgetViewModel: ObservableObject {
    
    @Published var budget: BudgetEntity
    @Published var period: PeriodEntity? = nil
    @Published var categories: [CategoryData] = []
    @Published var transactions: [TransactionEntity] = []
    
    @Published var totalPlannedIncome: Decimal
    @Published var totalPlannedFixedOutcome: Decimal
    @Published var totalPlannedPercentOutcome: Decimal
    @Published var totalPlannedPercentOutcomeAmount: Decimal
    @Published var totalOutcome: Decimal
    @Published var totalPlannedDailyOutcome: Decimal
    
    var currency: CurrencySymbol
    
    private var currencyFormatter: NumberFormatter
    private var percentFormatter: NumberFormatter
    private var dateFormatter: DateFormatter
    
    private let budgetService: BudgetService
    private let dataService: DataService
    
    var budgetCategories: [PlanCategoryEntity] {
        get {
            budget.categories?.allObjects as? [PlanCategoryEntity] ?? []
        }
    }
    
    init(budget: BudgetEntity, budgetService: BudgetService, dataService: DataService) {
        self.budget = budget
        self.budgetService = budgetService
        self.dataService = dataService
        let currency = dataService.getCurrencySymbolOrDefault(budget.currencyValue)
        self.currency = currency
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = currency.locale
        currencyFormatter.minimumFractionDigits = 0
        currencyFormatter.maximumFractionDigits = 2
        self.currencyFormatter = currencyFormatter
        
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = currency.locale
        percentFormatter.minimumFractionDigits = 0
        percentFormatter.maximumFractionDigits = 0
        self.percentFormatter = percentFormatter
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.setLocalizedDateFormatFromTemplate("MM-dd-yyyy HH:mm")
        self.dateFormatter = dateFormatter
        
        self.totalPlannedIncome = 0
        self.totalPlannedFixedOutcome = 0
        self.totalPlannedPercentOutcome = 0
        self.totalPlannedPercentOutcomeAmount = 0
        self.totalOutcome = 0
        self.totalPlannedDailyOutcome = 0
    }
    
    func loadCurrentBudgetPeriod() {
        do {
            period = try budgetService.getOrCreateLastPeriod(budget)
        } catch {
            // TODO: add notification
            print("Something went wrong \(error)")
        }
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
    
    func loadCategories() {
        guard let period = period else { return }
        
        do {
            let byCategory = try budgetService
                .getSpendingsForCategories(period, budget: budget, types: [.outcomeFixed, .outcomePercent])
                .reduce(into: [UUID:CategorySpendings]()) { result, spendings in
                result[spendings.id] = spendings
            }
            
            let onlySpendingCategories = budgetCategories.filter { $0.typeValue == .outcomeFixed || $0.typeValue == .outcomePercent }
            
            categories = onlySpendingCategories.map { category in
                if let categoryId = category.id, let spendings = byCategory[categoryId] {
                    return CategoryData(id: categoryId, entity: category, spendings: spendings)
                }
                
                return CategoryData(id: category.id!, entity: category,
                                    spendings: CategorySpendings(
                                        id: category.id ?? UUID(),
                                        totalAmount: 0,
                                        expectedAmount: 0,
                                        expectedPercent: 0)
                )
            }.sorted(by: { $0.entity.nameValue < $1.entity.nameValue })
        } catch {
            // TODO: shopw error
            print("Error \(error)")
        }
    }
    
    func updateAmounts() {
        guard let period = period
        else {
            return
        }
        
        totalPlannedIncome = budget.totalAmountForCategoryType(.income)
        totalPlannedFixedOutcome = budget.totalAmountForCategoryType(.outcomeFixed)
        totalPlannedPercentOutcome = budget.totalPercentForCategoryType(.outcomePercent)
        totalPlannedPercentOutcomeAmount = totalPlannedIncome * totalPlannedPercentOutcome
        
        let daysInPeriod = Calendar.current.numberOfDaysBetween(from: period.startsAt!, to: period.endsAt!)
        totalPlannedDailyOutcome = totalPlannedPercentOutcomeAmount / Decimal(daysInPeriod)
        
        do {
            totalOutcome = try budgetService.getTotalOutcomeForPeriod(period, budget: budget)
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
        }
    }
    
    func loadTransactions() {
        guard let period = period else { return }
        
        do {
            transactions = try budgetService.getAllTransactions(period, budget: budget)
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
        }
    }
    
    func deleteTransaction(_ transaction: TransactionEntity) {
        do {
            budgetService.deleteTransaction(transaction, budget: budget)
            try budgetService.save()
        } catch {
            // TODO: handle error
            print("Somwthing went wrong \(error)")
        }
        
        loadTransactions()
    }
    
}
