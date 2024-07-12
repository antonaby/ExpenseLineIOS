//
//  CategoryListViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 02.06.24.
//

import Foundation
import Combine


class CategoryListViewModel: ObservableObject {
    
    @Published var categories: [CategoryData] = []
    
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
                self?.loadCategories()
            }
        }
        .store(in: &cancellables)
    }
    
    func loadCategories() {
        do {
            let byCategory = try budgetService
                .getSpendingsForCategories(parent.period, budget: parent.budget, types: [.outcomeFixed, .outcomePercent])
                .reduce(into: [UUID:CategorySpendings]()) { result, spendings in
                result[spendings.id] = spendings
            }
            
            let onlySpendingCategories = parent.budget.allCategories.filter { $0.typeValue == .outcomeFixed || $0.typeValue == .outcomePercent }
            
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
            logErrorEvent(error)
            print("Something went wrong \(error)")
        }
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
    private func logErrorEvent(_ error: Error) {
        analyticsService.logEvent(name: AnalyticsService.DATA_ERROR, params: ["place": "budget_categories", "msg": "\(error)"])
    }
    
}
