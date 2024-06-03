//
//  BudgetOverviewViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 03.06.24.
//

import Foundation
import Combine


class BudgetOverviewViewModel: ObservableObject {
    
    var totalPlannedFixedOutcome: Decimal = 0
    var totalPlannedPercentOutcome: Decimal = 0
    var totalPlannedPercentOutcomeAmount: Decimal = 0
    var totalOutcome: Decimal = 0
    var totalFixedOutcome: Decimal = 0
    var totalPercentOutcome: Decimal = 0
    var totalBudgetLeft: Decimal = 0
    var totalFixedBudgetLeft: Decimal = 0
    var totalFlexibleBudgetLeft: Decimal = 0
    
    let parent: BudgetViewModel
    
    private let budgetService: BudgetService
    private var cancellables = Set<AnyCancellable>()
 
    init(parent: BudgetViewModel, budgetService: BudgetService) {
        self.parent = parent
        self.budgetService = budgetService
    }
    
    func subscribe() {
        parent.dataUpdateSubject.sink { [weak self] value in
            DispatchQueue.main.async {
                self?.loadAmounts()
            }
        }
        .store(in: &cancellables)
    }
    
    
    func loadAmounts() {
        totalPlannedFixedOutcome = parent.budget.totalAmountForCategoryType(.outcomeFixed)
        totalPlannedPercentOutcome = parent.budget.totalPercentForCategoryType(.outcomePercent)
        totalPlannedPercentOutcomeAmount = parent.totalPlannedIncome * totalPlannedPercentOutcome
        
        do {
            totalFixedOutcome = try budgetService.getTotalOutcomeForPeriod(parent.period, budget: parent.budget, types: [.outcomeFixed])
            totalPercentOutcome = try budgetService.getTotalOutcomeForPeriod(parent.period, budget: parent.budget, types: [.outcomePercent])
            totalOutcome = totalFixedOutcome + totalPercentOutcome
            totalBudgetLeft = parent.totalPlannedIncome - totalOutcome
            totalFixedBudgetLeft = totalPlannedFixedOutcome - totalFixedOutcome
            totalFlexibleBudgetLeft = totalPlannedPercentOutcomeAmount - totalPercentOutcome
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
        }
        
        objectWillChange.send()
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
}
