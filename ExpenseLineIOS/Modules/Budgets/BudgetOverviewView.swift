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
    
    @Binding var currentExpenses: Decimal
    @Binding var plannedExpenses: Decimal
    
    var currency: String
    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 5) {
                Text("Average Daily Spending")
                    .font(.title)
                Text("Money you can spend today")
                    .tint(.gray)
                    .font(.caption)
                HStack(alignment: .lastTextBaseline) {
                    Text("\(currentExpenses)")
                        .font(.largeTitle)
                    Text(currency)
                        .font(.title3)
                }
                .padding([.top], 10)
                ProgressView(percent: getTotalPercent())
                HStack(alignment: .lastTextBaseline) {
                    Text("\(plannedExpenses)")
                    Text(currency)
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
        if currentExpenses <= 0 {
            return 0
        }
        
        if plannedExpenses <= 0 {
            return 1
        }
        
        let percent = currentExpenses / plannedExpenses
        if percent > 1 {
            return 1
        }
        
        return (percent as NSDecimalNumber).doubleValue
    }
}


struct BudgetOverviewView: View {
    
    @ObservedObject var vm: BudgetViewModel
    @Binding var transactionSheet: Bool
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                DailyExpensesCard(
                    currentExpenses: $vm.currentDailyOutcome,
                    plannedExpenses: $vm.plannedDailyOutcome,
                    currency: vm.getCurrency()
                )
                Spacer()
            }
            AddExpenseButton {
                transactionSheet.toggle()
            }
            .offset(y: -10)
        }.background(Color(uiColor: .secondarySystemBackground))
    }
}

#Preview {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
   
    let appState = AppState(budgetService: bundle.budgetService)
    appState.selectBudget(budget)
    
    if let vm = appState.budgetViewModel(budget) {
        vm.currentDailyOutcome = 20
        vm.plannedDailyOutcome = 100
        return BudgetOverviewView(vm: vm, transactionSheet: .constant(false))
            .environmentObject(appState)
            .modifier(ServiceBundleViewModifier(bundle: bundle))
    } else {
        return Text("Seomthing went wrong")
    }
}
