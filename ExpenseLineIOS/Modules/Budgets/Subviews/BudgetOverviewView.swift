//
//  BudgetOverviewView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 11.04.24.
//

import SwiftUI

struct BudgetOverviewView: View {
    
    @ObservedObject var vm: BudgetViewModel
    
    var body: some View {
        VStack {
            CirclularBudgetProgressView(
                progress: [
                    getTotalSpent(),
                    getFixedSpent(),
                    getPercentSpent()
                ],
                colors: [.green, .purple, .orange]
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
            Grid {
                GridRow {
                    SpendingTitleView("Spent", color: .green)
                    SpendingTitleView("Left", color: .green.opacity(0.3))
                }
                GridRow {
                    AmountView(vm.totalOutcome) {
                        vm.totalPlannedFixedOutcome + vm.totalPlannedPercentOutcomeAmount - $0 < 0
                    }
                    AmountView(vm.totalBudgetLeft) {
                        $0 < 0
                    }
                }
                .font(.title2)
                .frame(maxWidth: .infinity)
                GridRow {
                    SpendingTitleView("Fixed", color: .purple)
                    SpendingTitleView("Flexible", color: .orange)
                }
                
                GridRow {
                    AmountView(vm.totalFixedOutcome) {
                        vm.totalPlannedFixedOutcome - $0 < 0
                    }
                    AmountView(vm.totalPercentOutcome) {
                        vm.totalPlannedPercentOutcomeAmount - $0 < 0
                    }
                }
                .font(.title2)
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 15)
        .onAppear {
            vm.updateAmounts()
        }
    }
    
    @ViewBuilder
    func AmountView(_ amount: Decimal, isSpent: (Decimal) -> Bool) -> some View {
        Text(vm.formatAmount(amount))
            .foregroundColor(isSpent(amount) ? .red : .black)
    }
    
    @ViewBuilder
    func SpendingTitleView(_ text: String, color: Color) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 3, style: .circular)
                .foregroundColor(color)
                .frame(width: 15, height: 15)
            Text(text)
        }
        .font(.caption)
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
            return 1
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
   
    let vm = BudgetViewModel(
        budget: budget, budgetService: bundle.budgetService, dataService: bundle.dataService
    )
    
    vm.totalPlannedIncome = 3500
    vm.totalPlannedFixedOutcome = 600
    vm.totalPlannedPercentOutcomeAmount = 1500
    vm.totalOutcome = 2000
    vm.totalBudgetLeft = 1500
    vm.totalFixedOutcome = 450
    vm.totalPercentOutcome = 1000

    return BudgetOverviewView(vm: vm)
        .serviceBundle(bundle)
}

#Preview("Almost") {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    budget.currency = "en_US"
   
    let vm = BudgetViewModel(
        budget: budget, budgetService: bundle.budgetService, dataService: bundle.dataService
    )
    
    vm.totalPlannedIncome = 3500
    vm.totalPlannedFixedOutcome = 600
    vm.totalPlannedPercentOutcomeAmount = 1500
    vm.totalOutcome = 2000
    vm.totalBudgetLeft = 1500
    vm.totalFixedOutcome = 450
    vm.totalPercentOutcome = 1550

    return BudgetOverviewView(vm: vm)
        .serviceBundle(bundle)
}

#Preview("Spent") {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    budget.currency = "en_US"
   
    let vm = BudgetViewModel(
        budget: budget, budgetService: bundle.budgetService, dataService: bundle.dataService
    )
    
    vm.totalPlannedIncome = 3500
    vm.totalPlannedFixedOutcome = 600
    vm.totalPlannedPercentOutcomeAmount = 1500
    vm.totalOutcome = 4000
    vm.totalBudgetLeft = -500
    vm.totalFixedOutcome = 650
    vm.totalPercentOutcome = 1550

    return BudgetOverviewView(vm: vm)
        .serviceBundle(bundle)
}
