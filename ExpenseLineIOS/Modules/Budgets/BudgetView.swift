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
    @State var editBudgetSheetOpen: Bool = false
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                ZStack {
                    Button {
                        appState.unselectBudget()
                    } label: {
                        Text(vm.budget.name ?? "Unknown")
                            .font(.title2)
                            .tint(.black)
                    }
                    .frame(maxWidth: .infinity)
                    Button {
                        editBudgetSheetOpen.toggle()
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding([.trailing], 10)
                }
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
            .fullScreenCover(isPresented: $editBudgetSheetOpen, onDismiss: onBudgetUpdated) {
                getWizardView()
            }
            .onAppear {
                vm.updateAmounts()
            }
        }
    }
    
    func onBudgetUpdated() {
        
    }
    
    func getWizardView() -> some View {
        do {
            let vm = try resolver.budgetWizzardViewModel(budget: vm.budget)
            return AnyView(BudgetWizardView(vm: vm, editMode: true))
        } catch {
            // TODO: show error
            return AnyView(Text("Something went wrong \(error)"))
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
