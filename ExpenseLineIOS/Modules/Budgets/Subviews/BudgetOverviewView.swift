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
            CircularProgressView(progress: getTotalPercentSpent()) {
                VStack {
                    Text(vm.formatPercent(getTotalPercentSpentDecimal()))
                        .font(.title)
                        .bold()
                    Text("Spent")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            .frame(width: 150, height: 150)
            Grid {
                GridRow {
                    Text("Spent")
                    Text("Left")
                }
                .font(.caption)
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
                    Text("Fixed")
                    Text("Flexible")
                }
                .font(.caption)
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
    
    func getTotalPercentSpentDecimal() -> Decimal {
        if vm.totalPlannedIncome <= 0 {
            return 1
        }
        if vm.totalOutcome <= 0 {
            return 0
        }
        
        return vm.totalOutcome / vm.totalPlannedIncome
    }
    
    func getTotalPercentSpent() -> Double {
        return Double(truncating: getTotalPercentSpentDecimal() as NSNumber)
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
    vm.totalPercentOutcome = 1450

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
