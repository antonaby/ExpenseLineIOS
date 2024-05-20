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
            HStack {
                Image(systemName: "arrow.down")
                    .foregroundColor(.red)
                Text(vm.formatAmount(vm.totalOutcome))
            }
            .font(.largeTitle)
            HStack {
                VStack {
                    HStack {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.green)
                        Text("Budget")
                    }
                    Text(vm.formatAmount(vm.totalPlannedIncome))
                        .font(.title2)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                Divider()
                    .frame(height: 50)
                VStack {
                    HStack {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.green)
                        Text("Daily")
                    }
                    Text(vm.formatAmount(vm.totalPlannedDailyOutcome))
                        .font(.title2)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            HStack {
                VStack {
                    HStack {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.red)
                        Text("Fixed")
                    }
                    Text(vm.formatAmount(vm.totalPlannedFixedOutcome))
                        .font(.title2)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                Divider()
                    .frame(height: 50)
                VStack {
                    HStack {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.red)
                        Text("Dynamic")
                    }
                    HStack {
                        Text(vm.formatPercent(vm.totalPlannedPercentOutcome))
                            .font(.title2)
                        Text("≈" + vm.formatAmount(vm.totalPlannedPercentOutcomeAmount))
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(.horizontal, 15)
        .onAppear {
            vm.updateAmounts()
        }
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

#Preview {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    budget.currency = "en_US"
   
    let vm = BudgetViewModel(
        budget: budget, budgetService: bundle.budgetService, dataService: bundle.dataService
    )

    return BudgetOverviewView(vm: vm)
        .serviceBundle(bundle)
}
