//
//  HomeViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation

enum BudgetViewPage: Hashable {
    case overview
    case categories
    case transactions
    case stats
}

class BudgetViewModel: ObservableObject {
    
    @Published var currenPage: BudgetViewPage
    
    @Published var budget: BudgetEntity
    @Published var period: PeriodEntity? = nil
    @Published var categories: [CategoryData] = []
    @Published var transactions: [TransactionEntity] = []
    @Published var daySpendings: [SpenginsStat] = []
    @Published var monthSpendings: [SpenginsStat] = []
    
    var currency: CurrencySymbol
    
    var totalPlannedIncome: Decimal = 0
    var totalPlannedFixedOutcome: Decimal = 0
    var totalPlannedPercentOutcome: Decimal = 0
    var totalPlannedPercentOutcomeAmount: Decimal = 0
    var totalOutcome: Decimal = 0
    var totalFixedOutcome: Decimal = 0
    var totalPercentOutcome: Decimal = 0
    var totalBudgetLeft: Decimal = 0
    var totalFixedBudgetLeft: Decimal = 0
    var totalFlexibleBudgetLeft: Decimal = 0
    
    private var currencyFormatter: NumberFormatter = NumberFormatter()
    private var percentFormatter: NumberFormatter = NumberFormatter()
    private var dateFormatter: DateFormatter = DateFormatter()
    
    private let budgetService: BudgetService
    private let dataService: DataService
    
    var budgetCategories: [PlanCategoryEntity] {
        get {
            budget.categories?.allObjects as? [PlanCategoryEntity] ?? []
        }
    }
    
    init(budget: BudgetEntity, page: BudgetViewPage = .overview, budgetService: BudgetService, dataService: DataService) {
        self.budget = budget
        self.currenPage = page
        self.budgetService = budgetService
        self.dataService = dataService
        self.currency = dataService.getCurrencySymbolOrDefault(budget.currencyValue)
        createFormatters(locale: currency.locale)
    }
    
    func loadCurrentBudgetPeriod() {
        do {
            period = try budgetService.getOrCreateLastPeriod(budget)
        } catch {
            // TODO: add notification
            print("Something went wrong \(error)")
        }
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
    
    func reloadPage() {
        loadData(for: currenPage)
    }
    
    func loadData(for page: BudgetViewPage) {
        switch page {
        case .overview:
            loadAmounts()
            break
        case .categories:
            loadCategories()
            break
        case .transactions:
            loadTransactions()
            break
        case .stats:
            loadDaySpendings()
            loadMonthSpendings()
            break
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
    
    private func loadAmounts() {
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
            totalFixedBudgetLeft = totalPlannedFixedOutcome - totalFixedOutcome
            totalFlexibleBudgetLeft = totalPlannedPercentOutcomeAmount - totalPercentOutcome
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
        }
        
        objectWillChange.send()
    }
    
    private func loadCategories() {
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
    
    private func loadTransactions() {
        guard let period = period else { return }
        
        do {
            transactions = try budgetService.getAllTransactions(period, budget: budget)
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
        }
    }
    
    private func loadDaySpendings() {
        guard let period = period else { return }
        
        do {
            daySpendings = try budgetService.getSpendingsForPeriodByDay(period, budget: budget, types: [.outcomeFixed, .outcomePercent])
        } catch {
            // TODO: handle error
            print("Something went wrong \(error)")
        }
    }
    
    private func loadMonthSpendings() {
        do {
            monthSpendings = try budgetService.getSpendingsForLastNPeriods(for: 12, budget: budget, types: [.outcomeFixed, .outcomePercent])
        } catch {
            // TODO: handle error
            print("Something went wrong \(error)")
        }
    }
    
}
