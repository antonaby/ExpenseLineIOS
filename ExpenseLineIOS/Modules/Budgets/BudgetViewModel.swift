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
    
    @Published var totalPlannedIncomeAmount: Decimal
    @Published var totalPlannedDynamicPercent: Decimal
    @Published var totalFixedOutcomeAmount: Decimal
    @Published var totalDynamicOutcomeAmount: Decimal
    @Published var plannedDailyOutcome: Decimal
    @Published var currentDailyOutcome: Decimal
            
    private let budgetService: BudgetService
    let categories: [PlanCategoryEntity]
    
    init(budget: BudgetEntity, budgetService: BudgetService) {
        self.budget = budget
        self.budgetService = budgetService
        self.categories = budget.categories?.allObjects as? [PlanCategoryEntity] ?? []
        
        self.totalPlannedIncomeAmount = 0
        self.totalPlannedDynamicPercent = 0
        self.totalFixedOutcomeAmount = 0
        self.totalDynamicOutcomeAmount = 0
        self.plannedDailyOutcome = 0
        self.currentDailyOutcome = 0
    }
    
    func loadCurrentBudgetPeriod() {
        do {
            period = try budgetService.getOrCreateLastPeriod(budget)
        } catch {
            // TODO: add notification
            print("Something went wrong \(error)")
        }
    }
    
        
    func getCurrency() -> String {
        // TODO: add proper currency
        budget.currency ?? "USD"
    }
    
    func getCategoryInfos() -> [CategoryInfo] {
        guard let period = period else { return [] }
        
        do {
            let byCategory = try budgetService
                .spendingsForAllCategories(period, budget: budget)
                .reduce(into: [UUID:CategorySpendings]()) { result, spendings in
                result[spendings.id] = spendings
            }
            
            return categories.map { category in
                if let categoryId = category.id, let spendings = byCategory[categoryId] {
                    return CategoryInfo(id: categoryId, entity: category, spendings: spendings)
                }
                
                return CategoryInfo(id: category.id!, entity: category, spendings: nil)
            }
        } catch {
            // TODO: shopw error
            print("Error \(error)")
            return []
        }
    }
    
    func updateAmounts() {
        guard let period = period else { return }
        
        totalPlannedIncomeAmount = categories
            .filter { $0.typeValue == .income }
            .reduce(0) { $0 + $1.amountDecimal }
        
        totalPlannedDynamicPercent = categories
            .filter { $0.typeValue == .outcomePercent }
            .reduce(0) { $0 + $1.percentDecimalFraction }
        
        do {
            let fixedCategories = try budgetService.spendingsForFixedCategories(period, budget: budget)
            totalFixedOutcomeAmount = fixedCategories.reduce(0) { $0 + $1.totalAmount }
            
            let dynamicCategories = try budgetService.spendingsForDynamicCategories(period, budget: budget)
            totalDynamicOutcomeAmount = dynamicCategories.reduce(0) { $0 + $1.totalAmount }
            
            calculatePlannedDailyOutcome(totalPlannedIncomeAmount * totalPlannedDynamicPercent, totalDynamicOutcomeAmount)
        } catch {
            // TODO: shopw error
            print("Error \(error)")
        }
    }
    
    func getAllTransactions() -> [TransactionEntity] {
        guard let period = period else { return [] }
        
        do {
            return try budgetService.getAllTransactions(period, budget: budget)
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
            return []
        }
    }
    
    private func calculatePlannedDailyOutcome(_ plannedDynamicAmount: Decimal, _ currentDynamicAmount: Decimal) {
        guard let startsAt = period?.startsAt, let endsAt = period?.endsAt
        else {
            return
        }
        
        // TODO: check a number of days (+1)
        let totalDays = Calendar.current.dateComponents([.day], from: startsAt, to: endsAt).day! + 1
        plannedDailyOutcome = plannedDynamicAmount / Decimal(totalDays)
        
        let pastDays = Calendar.current.dateComponents([.day], from: startsAt, to: Date()).day! + 1
        currentDailyOutcome = currentDynamicAmount / Decimal(pastDays)
    }
   
}
