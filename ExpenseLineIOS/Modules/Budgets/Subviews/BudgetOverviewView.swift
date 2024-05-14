//
//  BudgetOverviewView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 11.04.24.
//

import SwiftUI


struct ProgressView: View {
    
    var percent: Double
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .foregroundColor(.green)
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .frame(width: proxy.size.width * percent, alignment: .leading)
                    .foregroundColor(.red)
            }
        }.frame(maxHeight: 10)
    }
    
}

struct DailyExpensesCard: View {
    
    @ObservedObject var vm: BudgetViewModel
    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 5) {
                Text("Average Daily Spending")
                    .font(.title)
                Text("Money you can spend today")
                    .tint(.gray)
                    .font(.caption)
                HStack {
                    Text(vm.formatAmount(vm.currentDailyOutcome))
                        .font(.largeTitle)
                }
                .padding([.top], 10)
                ProgressView(percent: getTotalPercent())
                HStack(alignment: .lastTextBaseline) {
                    Text(vm.formatAmount(0))
                        .font(.caption)
                    Spacer()
                    Text(vm.formatAmount(vm.plannedDailyOutcome))
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal], 15)
            .padding([.vertical], 5)
        }
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
    }
    
    func getTotalPercent() -> Double {
        if vm.currentDailyOutcome <= 0 {
            return 0
        }
        
        if vm.plannedDailyOutcome <= 0 {
            return 1
        }
        
        let percent = vm.currentDailyOutcome / vm.plannedDailyOutcome
        if percent > 1 {
            return 1
        }
        
        return (percent as NSDecimalNumber).doubleValue
    }
}

struct BudgetOverviewView: View {
    
    @ObservedObject var vm: BudgetViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                DailyExpensesCard(vm: vm)
                Spacer()
            }
        }.background(Color(uiColor: .secondarySystemBackground))
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
    vm.currentDailyOutcome = 20
    vm.plannedDailyOutcome = 100
    return BudgetOverviewView(vm: vm)
        .serviceBundle(bundle)
}
