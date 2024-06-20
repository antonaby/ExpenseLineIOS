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
    @Published var startsAt: Date
    @Published var endsAt: Date
    
    let parent: BudgetViewModel
    
    private let budgetService: BudgetService
    private var cancellables = Set<AnyCancellable>()
    
    init(parent: BudgetViewModel, budgetService: BudgetService) {
        self.parent = parent
        self.budgetService = budgetService
        self.startsAt = parent.period.startsAt ?? Date().firstDayOfMonth()
        self.endsAt = parent.period.endsAt ?? Date().lastDayOfMonth()
    }
    
    func clearSearchFilter() {
        serachFilter = ""
        startsAt = parent.period.startsAt ?? Date().firstDayOfMonth()
        endsAt = parent.period.endsAt ?? Date().lastDayOfMonth()
    }
    
    func subscribe() {
        parent.dataUpdateSubject.sink { [weak self] value in
            DispatchQueue.main.async {
                if let self = self {
                    self.serachFilter = ""
                    self.startsAt = self.parent.period.startsAt ?? Date().firstDayOfMonth()
                    self.endsAt = self.parent.period.endsAt ?? Date().lastDayOfMonth()
                }
            }
        }
        .store(in: &cancellables)
        
        $serachFilter
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.loadTransactions()
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest($startsAt, $endsAt)
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.loadTransactions()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadTransactions() {
        do {
            if serachFilter.isEmpty {
                transactions = try budgetService.getAllTransactions(startsAt: startsAt, endsAt: endsAt, budget: parent.budget)
            } else {
                transactions = try budgetService.searchTransactions(serachFilter, startsAt: startsAt, endsAt: endsAt, budget: parent.budget)
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
