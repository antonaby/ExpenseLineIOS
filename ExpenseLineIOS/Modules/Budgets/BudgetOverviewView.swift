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
            HStack {
                Text(vm.totalAmount, format: .number.rounded(increment: 0.01))
                    .font(.title)
                Text(vm.getCurrency())
                    .font(.title2)
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
