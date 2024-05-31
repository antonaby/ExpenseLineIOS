//
//  BudgetOverviewView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 11.04.24.
//

import SwiftUI

struct BudgetOverviewView: View {
    
    @EnvironmentObject var setting: SettingsService
    @ObservedObject var vm: BudgetViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                CirclularBudgetProgressView(
                    progress: [
                        getTotalSpent(),
                        getFixedSpent(),
                        getPercentSpent()
                    ],
                    colors: [.green, .purple, .orange],
                    gap: setting.getBoolPreference(for: SettingsService.GAPS_IN_CIRCLE)
                ) {
                    VStack {
                        Text(vm.formatPercent(getTotalSpentDecimal()))
                            .font(.title)
                            .bold()
                        Text("Spent")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
                .frame(width: 250, height: 250)
                .padding()
                VStack(alignment: .leading) {
                    SpendingsView(
                        title: "Spendings",
                        firstColor: .green,
                        secondColor: .green.opacity(0.3),
                        left: { AmountView(vm.totalOutcome) {
                            vm.totalPlannedFixedOutcome + vm.totalPlannedPercentOutcomeAmount - $0 < 0
                        }},
                        right: { AmountView(vm.totalBudgetLeft) {
                            $0 < 0
                        }
                    })
                    SpendingsView(
                        title: "Fixed",
                        firstColor: .purple,
                        secondColor: .purple.opacity(0.3),
                        left: { AmountView(vm.totalFixedOutcome) {
                            vm.totalPlannedFixedOutcome - $0 < 0
                        }},
                        right: { AmountView(vm.totalFixedBudgetLeft) {
                            $0 < 0
                        }
                    })
                    SpendingsView(
                        title: "Flexible",
                        firstColor: .orange,
                        secondColor: .orange.opacity(0.3),
                        left: { AmountView(vm.totalPercentOutcome) {
                            vm.totalPlannedPercentOutcomeAmount - $0 < 0
                        }},
                        right: { AmountView(vm.totalFlexibleBudgetLeft) {
                            $0 < 0
                        }
                    })
                }
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            vm.loadData(for: .overview)
        }
    }
    
    @ViewBuilder
    func AmountView(_ amount: Decimal, isSpent: (Decimal) -> Bool) -> some View {
        Text(vm.formatAmount(amount))
            .foregroundColor(isSpent(amount) ? .red : .black)
            .font(.title2)
    }
    
    @ViewBuilder
    func SpendingsView(
        title: String,
        firstColor: Color,
        secondColor: Color,
        @ViewBuilder left: () -> some View,
        @ViewBuilder right: () -> some View
    ) -> some View {
        VStack(alignment: .leading) {
            HStack {
                RoundedRectangle(cornerRadius: 3, style: .circular)
                    .foregroundColor(firstColor)
                    .frame(width: 15, height: 15)
                RoundedRectangle(cornerRadius: 3, style: .circular)
                    .foregroundColor(secondColor)
                    .frame(width: 15, height: 15)
                Text(title)
            }
            .frame(alignment: .leading)
            HStack {
                left()
                Divider()
                right()
            }
            .frame(alignment: .leading)
        }
    }
    
    func getTotalSpentDecimal() -> Decimal {
        if vm.totalPlannedIncome <= 0 {
            return 1
        }
        if vm.totalOutcome <= 0 {
            return 0
        }
        
        return vm.totalOutcome / vm.totalPlannedIncome
    }
    
    func getTotalSpent() -> Double {
        return Double(truncating: getTotalSpentDecimal() as NSNumber)
    }
    
    func getFixedSpent() -> Double {
        if vm.totalPlannedFixedOutcome <= 0 {
            return 0
        }
        if vm.totalFixedOutcome <= 0 {
            return 0
        }
        
        let total = vm.totalFixedOutcome / vm.totalPlannedFixedOutcome
        return Double(truncating: total as NSNumber)
    }
    
    func getPercentSpent() -> Double {
        if vm.totalPlannedPercentOutcomeAmount <= 0 {
            return 1
        }
        if vm.totalPercentOutcome <= 0 {
            return 0
        }
        
        let total = vm.totalPercentOutcome / vm.totalPlannedPercentOutcomeAmount
        return Double(truncating: total as NSNumber)
    }
}

#Preview("OK") {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    budget.currency = "en_US"
   
    do {
        let vm = BudgetViewModel(
            budget: budget,
            period: try bundle.budgetService.getOrCreateLastPeriod(budget),
            budgetService: bundle.budgetService, dataService: bundle.dataService
        )
        
        vm.totalPlannedIncome = 3500
        vm.totalPlannedFixedOutcome = 600
        vm.totalPlannedPercentOutcomeAmount = 1500
        vm.totalOutcome = 2000
        vm.totalBudgetLeft = 1500
        vm.totalFixedOutcome = 450
        vm.totalPercentOutcome = 1000
        vm.totalFixedBudgetLeft = 1000
        vm.totalFlexibleBudgetLeft = 500
        
        bundle.settingsService.setBoolPreference(for: SettingsService.GAPS_IN_CIRCLE, value: false)
        
        return BudgetOverviewView(vm: vm)
            .serviceBundle(bundle)
    } catch {
        return Text("Something went wrong \(error)")
    }
}

#Preview("Almost") {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    budget.currency = "en_US"
   
    do {
        let vm = BudgetViewModel(
            budget: budget,
            period: try bundle.budgetService.getOrCreateLastPeriod(budget),
            budgetService: bundle.budgetService, dataService: bundle.dataService
        )
        
        vm.totalPlannedIncome = 3500
        vm.totalPlannedFixedOutcome = 600
        vm.totalPlannedPercentOutcomeAmount = 1500
        vm.totalOutcome = 2000
        vm.totalBudgetLeft = 1500
        vm.totalFixedOutcome = 450
        vm.totalPercentOutcome = 1550
        vm.totalFixedBudgetLeft = 1000
        vm.totalFlexibleBudgetLeft = 500
        
        bundle.settingsService.setBoolPreference(for: SettingsService.GAPS_IN_CIRCLE, value: true)
        
        return BudgetOverviewView(vm: vm)
            .serviceBundle(bundle)
    } catch {
        return Text("Something went wrong \(error)")
    }
}

#Preview("Spent") {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    budget.currency = "en_US"
   
    do {
        let vm = BudgetViewModel(
            budget: budget,
            period: try bundle.budgetService.getOrCreateLastPeriod(budget),
            budgetService: bundle.budgetService, dataService: bundle.dataService
        )
        
        vm.totalPlannedIncome = 3500
        vm.totalPlannedFixedOutcome = 600
        vm.totalPlannedPercentOutcomeAmount = 1500
        vm.totalOutcome = 4000
        vm.totalBudgetLeft = -500
        vm.totalFixedOutcome = 650
        vm.totalPercentOutcome = 1550
        vm.totalFixedBudgetLeft = 1000
        vm.totalFlexibleBudgetLeft = 500
        
        bundle.settingsService.setBoolPreference(for: SettingsService.GAPS_IN_CIRCLE, value: false)
        
        return BudgetOverviewView(vm: vm)
            .serviceBundle(bundle)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
