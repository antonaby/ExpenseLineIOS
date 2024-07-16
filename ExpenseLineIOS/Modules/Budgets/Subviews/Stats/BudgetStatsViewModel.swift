//
//  BudgetStatsViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 03.06.24.
//

import Foundation
import Combine


class BudgetStatsViewModel: ObservableObject {
    
    @Published var daySpendings: [SpenginsStat] = []
    @Published var monthSpendings: [SpenginsStat] = []
    
    let parent: BudgetViewModel
    
    private let budgetService: BudgetService
    private let analyticsService: AnalyticsService
    private var cancellables = Set<AnyCancellable>()
    
    init(parent: BudgetViewModel, budgetService: BudgetService, analyticsService: AnalyticsService) {
        self.parent = parent
        self.budgetService = budgetService
        self.analyticsService = analyticsService
    }
    
    func subscribe() {
        parent.dataUpdateSubject.sink { [weak self] value in
            DispatchQueue.main.async {
                self?.loadSpendings()
            }
        }
        .store(in: &cancellables)
    }
    
    func loadSpendings() {
        do {
            daySpendings = try budgetService.getSpendingsForPeriodByDay(parent.period, budget: parent.budget, types: [.outcomeFixed, .outcomePercent])
            monthSpendings = try budgetService.getSpendingsForLastNPeriods(for: 12, budget: parent.budget, types: [.outcomeFixed, .outcomePercent])
        } catch {
            logErrorEvent(error)
            print("Something went wrong \(error)")
        }
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
    private func logErrorEvent(_ error: Error) {
        analyticsService.logError(place: "budget_stats", error: error)
    }
    
}
