//
//  MainView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI


struct BudgetView: View {
    
    @StateObject var vm: BudgetViewModel
    
    @Binding var path: NavigationPath
    
    @EnvironmentObject var resolver: DependencyResolver
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    Button {
                        appState.unselectBudget()
                    } label: {
                        Text(vm.bugget.name ?? "Unknown")
                            .font(.title3)
                            .tint(.black)
                    }
                    .frame(maxWidth: .infinity)
                    Text("")
                    Spacer()
                }
                AddExpenseButton {
                    
                }
            }
            .padding([.horizontal], 15)
            .onAppear {
                
            }
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
    
    return BudgetView(vm: DependencyResolver.preview.budgetViewModel(budget), path: .constant(NavigationPath()))
        .environmentObject(DependencyResolver.preview)
        .environmentObject(appState)
}
