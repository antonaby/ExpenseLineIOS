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
    @Published var daySpendings: [SpenginsStat] = []
    @Published var monthSpendings: [SpenginsStat] = []
    
    var totalPlannedIncome: Decimal
    var totalPlannedFixedOutcome: Decimal
    var totalPlannedPercentOutcome: Decimal
    var totalPlannedPercentOutcomeAmount: Decimal
    var totalOutcome: Decimal
    var totalFixedOutcome: Decimal
    var totalPercentOutcome: Decimal
    var totalBudgetLeft: Decimal
    
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
        self.totalFixedOutcome = 0
        self.totalPercentOutcome = 0
        self.totalBudgetLeft = 0
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
        
        do {
            totalFixedOutcome = try budgetService.getTotalOutcomeForPeriod(period, budget: budget, types: [.outcomeFixed])
            totalPercentOutcome = try budgetService.getTotalOutcomeForPeriod(period, budget: budget, types: [.outcomePercent])
            totalOutcome = totalFixedOutcome + totalPercentOutcome
            totalBudgetLeft = totalPlannedIncome - totalOutcome
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
        }
        
        objectWillChange.send()
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
    
    func loadDaySpendings() {
        daySpendings = [
            SpenginsStat(id: 0, date: Date(), value: 10),
            SpenginsStat(id: 1, date: Date().plusDay(1), value: 20),
            SpenginsStat(id: 2, date: Date().plusDay(2), value: 10),
            SpenginsStat(id: 3, date: Date().plusDay(3), value: 40),
            SpenginsStat(id: 4, date: Date().plusDay(4), value: 100),
            SpenginsStat(id: 5, date: Date().plusDay(5), value: 20),
            SpenginsStat(id: 6, date: Date().plusDay(6), value: 15),
            SpenginsStat(id: 7, date: Date().plusDay(7), value: 0),
            SpenginsStat(id: 8, date: Date().plusDay(8), value: 20),
            SpenginsStat(id: 9, date: Date().plusDay(9), value: 80),
        ]
    }
    
    func loadMonthSpendings() {
        monthSpendings = [
            SpenginsStat(id: 0, date: Date(), value: 10),
            SpenginsStat(id: 1, date: Date().plusMonth(-1), value: 200),
            SpenginsStat(id: 2, date: Date().plusMonth(-2), value: 100),
            SpenginsStat(id: 3, date: Date().plusMonth(-3), value: 400),
            SpenginsStat(id: 4, date: Date().plusMonth(-4), value: 1000),
            SpenginsStat(id: 5, date: Date().plusMonth(-5), value: 200),
            SpenginsStat(id: 6, date: Date().plusMonth(-6), value: 150),
            SpenginsStat(id: 7, date: Date().plusMonth(-7), value: 10),
            SpenginsStat(id: 8, date: Date().plusMonth(-8), value: 200),
            SpenginsStat(id: 9, date: Date().plusMonth(-9), value: 800),
        ]
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
