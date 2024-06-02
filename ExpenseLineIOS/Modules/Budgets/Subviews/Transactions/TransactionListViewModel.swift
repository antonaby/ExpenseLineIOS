//
//  TransactionListViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 31.05.24.
//

import Foundation
import Combine

class TransactionListViewModel: ObservableObject {
    
    @Published var serachFilter: String = ""
    @Published var transactions: [TransactionEntity] = []
    
    let parent: BudgetViewModel
    
    private let budgetService: BudgetService
    private var cancellables = Set<AnyCancellable>()
    
    init(parent: BudgetViewModel, budgetService: BudgetService) {
        self.parent = parent
        self.budgetService = budgetService
    }
    
    func subscribe() {
        parent.dataUpdateSubject.sink { [weak self] value in
            self?.serachFilter = ""
        }
        .store(in: &cancellables)
        
        $serachFilter
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                DispatchQueue.main.async {
                    self?.loadTransactions(filter: value)
                }
            }
            .store(in: &cancellables)
    }
    
    func loadTransactions(filter: String) {
        do {
            if filter.isEmpty {
                transactions = try budgetService.getAllTransactions(parent.period, budget: parent.budget)
            } else {
                transactions = try budgetService.searchTransactions(filter, period: parent.period, budget: parent.budget)
            }
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
        }
    }
    
    func deleteTransaction(_ transaction: TransactionEntity) {
        do {
            budgetService.deleteTransaction(transaction, budget: parent.budget)
            try budgetService.save()
        } catch {
            // TODO: handle error
            print("Somwthing went wrong \(error)")
        }
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
        cancellables = []
    }
    
}
