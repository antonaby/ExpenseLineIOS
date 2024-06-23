//
//  AppState.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import Foundation


class AppState: ObservableObject {
    
    @Published var showError: Bool?
    @Published var budget: BudgetEntity?
    @Published var paywall: Bool = false
    @Published var helpPage: HelpPage? = nil

    private let budgetService: BudgetService
    private let settingsService: SettingsService
    
    init(budgetService: BudgetService, settingsService: SettingsService) {
        self.budgetService = budgetService
        self.settingsService = settingsService
    }
    
    func selectBudget(_ budget: BudgetEntity) {
        self.budget = budget
        settingsService.setBudgetId(budget.id)
    }
    
    func unselectBudget() {
        budget = nil
        settingsService.setBudgetId(nil)
    }
    
    func loadBudget() {
        budget = getBudget()
    }
    
    func showPaywall() {
        paywall.toggle()
    }
    
    func showHelpPage(for page: HelpPage, firstTime: Bool = false) {
        if !firstTime || settingsService.alwaysShowHelp() {
            self.helpPage = page
            return
        }
        
        if !settingsService.getBoolPreference(for: page.rawValue) {
            self.helpPage = page
            settingsService.setBoolPreference(for: page.rawValue, value: true)
        }
    }
    
    func getBudgetViewModel(budget: BudgetEntity, budgetService: BudgetService, dataService: DataService) -> BudgetViewModel? {
        do {
            return BudgetViewModel(
                budget: budget,
                period: try budgetService.getOrCreateLastPeriod(budget),
                budgetService: budgetService,
                dataService: dataService)
        } catch {
            // TODO: hadnle error
            print("Somethiong went wrong \(error)")
            return nil
        }
    }

    private func getBudget() -> BudgetEntity? {
        if let budgetId = settingsService.getBudgetId() {
            do {
                return try budgetService.getBudgetById(budgetId)
            } catch {
                // TODO: show error
                print("Can't fetch budget info: \(error)")
            }
        }
        
        return nil
    }
    
}
