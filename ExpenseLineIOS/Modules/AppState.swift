//
//  AppState.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    
    @Published var path: NavigationPath = NavigationPath()
    @Published var showError: Bool?
    @Published var budget: BudgetEntity?
    @Published var paywall: Bool = false
    @Published var helpPage: HelpPage? = nil
    @Published var showNewBudgetPage: Bool = false

    private let bundle: ServiceBundle
    
    init(bundle: ServiceBundle) {
        self.bundle = bundle
    }
    
    func selectBudget(_ budget: BudgetEntity) {
        self.budget = budget
        bundle.settingsService.setBudgetId(budget.id)
    }
    
    func unselectBudget() {
        budget = nil
        bundle.settingsService.setBudgetId(nil)
    }
    
    func loadBudget() {
        let settings = bundle.settingsService
        if !settings.getBoolPreference(for: SettingsService.APP_FIRST_LAUNCH_DONE) {
            settings.setBoolPreference(for: SettingsService.APP_FIRST_LAUNCH_DONE, value: true)
            showNewBudgetPage = true
            return
        }
        
        budget = getBudget()
    }
    
    func showPaywall() {
        paywall.toggle()
    }
    
    func showHelpPage(for page: HelpPage, firstTime: Bool = false) {
        if !firstTime || bundle.settingsService.alwaysShowHelp() {
            self.helpPage = page
            return
        }
        
        if !bundle.settingsService.getBoolPreference(for: page.rawValue) {
            self.helpPage = page
            bundle.settingsService.setBoolPreference(for: page.rawValue, value: true)
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
    
    func newBudgetWizzardViewModel() -> BudgetWizardViewModel {
        let budget = bundle.budgetService.newBudgetEntity()
        budget.dailyRemainderAt = Date().currentDateAt(at: 20)
        for category in bundle.dataService.getDefaultCategories(budget: budget) {
            budget.addToCategories(category)
        }
        
        return BudgetWizardViewModel(budget,
                                     editMode: false,
                                     budgetService: bundle.budgetService,
                                     dataService: bundle.dataService,
                                     notificationService: bundle.notificationService)
    }

    private func getBudget() -> BudgetEntity? {
        if let budgetId = bundle.settingsService.getBudgetId() {
            do {
                return try bundle.budgetService.getBudgetById(budgetId)
            } catch {
                // TODO: show error
                print("Can't fetch budget info: \(error)")
            }
        }
        
        return nil
    }
    
}
