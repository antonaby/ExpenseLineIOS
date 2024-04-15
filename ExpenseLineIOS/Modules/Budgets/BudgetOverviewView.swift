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
            VStack {
                HStack {
                    Text(vm.currentDailyOutcome, format: .number.rounded(increment: 0.01))
                    Text("/")
                    Text(vm.plannedDailyOutcome, format: .number.rounded(increment: 0.01))
                }.font(.title)
                Text(vm.getCurrency())
            }
            HStack {
                Text(vm.totalDynamicOutcomeAmount + vm.totalFixedOutcomeAmount,
                     format: .number.rounded(increment: 0.01))
                Text(vm.getCurrency())
            }
            Spacer()
        }
    }
}

#Preview {
    let dm = DependencyResolver.preview.databaseManager()
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
   
    dm.save()
    
    let appState = AppState()
    appState.selectBudget(budget)
    
    do {
        let vm = try DependencyResolver.preview.budgetViewModel(budget)
        
        return BudgetOverviewView(vm: vm)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
