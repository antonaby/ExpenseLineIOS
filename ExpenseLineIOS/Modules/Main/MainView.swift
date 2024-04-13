//
//  MainView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 02.04.24.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if let budget = appState.budget {
                getBudget(budget)
            } else {
                getBudgetList()
            }
        }
        .environmentObject(appState.resolver)
        .environmentObject(appState)
        .onAppear {
            appState.loadBudget()
        }
    }
    
    func getBudget(_ budget: BudgetEntity) -> some View {
        do {
            let vm = try appState.resolver.budgetViewModel(budget)
            return AnyView(BudgetView(vm: vm, path: .constant(NavigationPath())))
        } catch {
            // TODO: Show error
            return AnyView(Text("Something went wrong \(error)"))
        }
    }
    
    func getBudgetList() -> some View {
        do {
            let vm = try appState.resolver.budgetListViewModel()
            return AnyView(BudgetListView(vm: vm))
        } catch {
            // TODO: Show error
            return AnyView(Text("Something went wrong \(error)"))
        }
    }
    
}

#Preview {
    MainView()
        .environmentObject(AppState())
}
