//
//  BaseView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import SwiftUI


struct BudgetListView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var resolver: DependencyResolver
    
    @StateObject var vm: BudgetListViewModel
    @State var isWizzardOpen = false
    @State var selectedBudget: BudgetEntity?
    
    var body: some View {
        VStack {
            Spacer()
            ForEach(vm.budgets) { budget in
                VStack {
                    Button {
                        appState.selectBudget(budget)
                    } label: {
                        HStack {
                            Text(budget.name ?? "Unknown")
                                .font(.title2)
                            Spacer()
                            Button {
                                selectedBudget = budget
                            } label: {
                                Text("Edit")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.horizontal], 10)
                        .padding([.vertical], 5)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(lineWidth: 1).background(Color.white))
                        .tint(.black)
                    }
                }
            }
            .padding([.horizontal], 10)
            HStack {
                Spacer()
                Button {
                    isWizzardOpen.toggle()
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .padding([.horizontal], 10)
            Spacer()
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .onAppear {
            vm.loadBudgets()
        }
        .fullScreenCover(item: $selectedBudget, onDismiss: onBudgetCreated) { budget in
            getWizardView(budget: budget)
        }
        .fullScreenCover(isPresented: $isWizzardOpen, onDismiss: onBudgetCreated) {
            getWizardView()
        }
    }
    
    func onBudgetCreated() {
        selectedBudget = nil
        vm.loadBudgets()
    }
    
    func getWizardView(budget: BudgetEntity? = nil) -> some View {
        do {
            let vm = try resolver.budgetWizzardViewModel(budget: budget)
            return AnyView(BudgetWizardView(vm: vm, editMode: false))
        } catch {
            // TODO: show error
            return AnyView(Text("Something went wrong \(error)"))
        }
    }
    
}

#Preview {
    let dm = DependencyResolver.preview.databaseManager()
    let budget1 = BudgetEntity(context: dm.viewContext)
    budget1.id = UUID()
    budget1.name = "Budget 1"
    
    let budget2 = BudgetEntity(context: dm.viewContext)
    budget2.id = UUID()
    budget2.name = "Budget 2"
    
    dm.save()
    
    do {
        let appState = AppState(DependencyResolver.preview)
        let vm = try DependencyResolver.preview.budgetListViewModel()
        return BudgetListView(vm: vm)
            .environmentObject(appState)
            .environmentObject(appState.resolver)
    } catch {
        return Text("Something went wrong \(error)")
    }
    
    
}
