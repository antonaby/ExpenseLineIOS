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
    
    @State var transactionSheet: Bool = false
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button {
                    appState.unselectBudget()
                } label: {
                    Text(vm.budget.name ?? "Unknown")
                        .font(.title2)
                        .tint(.black)
                }
                .frame(maxWidth: .infinity)
                Text(vm.getPeriodName())
                    .font(.caption)
                    .padding([.horizontal], 10)
                    .background(RoundedRectangle(cornerRadius: 3).foregroundColor(.green))
                TabView {
                    BudgetOverviewView(vm: vm, transactionSheet: $transactionSheet)
                        .tabItem { Image(systemName: "house") }
                    CategoryListView(vm: vm)
                        .tabItem { Image(systemName: "menucard") }
                    TransactionListView(vm: vm)
                        .tabItem { Image(systemName: "list.clipboard") }
                    BudgetStatsView()
                        .tabItem { Image(systemName: "chart.pie") }
                }
                .padding([.horizontal], 15)
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .sheet(isPresented: $transactionSheet, onDismiss: onCategoryUpdated) {
                getTransactionSheet()
                    .presentationDetents([.medium])
            }
            .onAppear {
                vm.updateAmounts()
            }
        }
    }
    
    func getTransactionSheet() -> AnyView {
        do {
            let vm = try resolver.transactionSheetViewModel(budget: vm.budget)
            return AnyView(TransactionSheetView(vm: vm))
        } catch {
            return AnyView(Text("Something went wrong \(error)"))
        }
    }
    
    func onCategoryUpdated() {
        vm.updateAmounts()
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
        
        return BudgetView(vm: vm, path: .constant(NavigationPath()))
            .environmentObject(DependencyResolver.preview)
            .environmentObject(appState)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
