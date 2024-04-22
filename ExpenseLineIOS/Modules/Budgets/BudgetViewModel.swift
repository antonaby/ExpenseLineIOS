//
//  HomeViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation


class BudgetViewModel: ObservableObject {
    
    @Published var budget: BudgetEntity
    @Published var period: PeriodEntity
    @Published var totalPlannedIncomeAmount: Double
    @Published var totalPlannedDynamicPercent: Double
    @Published var totalFixedOutcomeAmount: Double
    @Published var totalDynamicOutcomeAmount: Double
    @Published var plannedDailyOutcome: Double
    @Published var currentDailyOutcome: Double
    
        
    private let budgetService: BudgetService
    let categories: [PlanCategoryEntity]
    
    init(budget: BudgetEntity, period: PeriodEntity, categories: [PlanCategoryEntity], budgetService: BudgetService) {
        self.budget = budget
        self.period = period
        self.totalPlannedIncomeAmount = 0
        self.totalPlannedDynamicPercent = 0
        self.totalFixedOutcomeAmount = 0
        self.totalDynamicOutcomeAmount = 0
        self.plannedDailyOutcome = 0
        self.currentDailyOutcome = 0
        self.categories = categories
        self.budgetService = budgetService
    }
        
    func getCurrency() -> String {
        // TODO: add proper currency
        budget.currency ?? "USD"
    }
    
    func getCategoryInfos() -> [CategoryInfo] {
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
    
    func getPeriodName() -> String {
        guard let starts = period.startsAt else { return "Unknown" }
        
        let month = Calendar.current.component(.month, from: starts)
        return Calendar.current.monthSymbols[month - 1]
    }
    
    func updateAmounts() {
        totalPlannedIncomeAmount = categories
            .filter { $0.typeValue == .income }
            .reduce(0) { $0 + $1.amount }
        
        totalPlannedDynamicPercent = categories
            .filter { $0.typeValue == .outcomePercent }
            .reduce(0) { $0 + $1.percent }
        
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
        do {
            return try budgetService.getAllTransactions(period, budget: budget)
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
            return []
        }
    }
    
    private func calculatePlannedDailyOutcome(_ plannedDynamicAmount: Double, _ currentDynamicAmount: Double) {
        guard let startsAt = period.startsAt, let endsAt = period.endstAt
        else {
            return
        }
        
        // TODO: check a number of days (+1)
        let totalDays = Calendar.current.dateComponents([.day], from: startsAt, to: endsAt).day! + 1
        plannedDailyOutcome = plannedDynamicAmount / Double(totalDays)
        
        let pastDays = Calendar.current.dateComponents([.day], from: startsAt, to: Date()).day! + 1
        currentDailyOutcome = currentDynamicAmount / Double(pastDays)
    }
   
}
