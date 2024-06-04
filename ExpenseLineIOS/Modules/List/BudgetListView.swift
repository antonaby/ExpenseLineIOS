//
//  BaseView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.04.24.
//

import SwiftUI


struct BudgetListView: View {
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var vm: BudgetListViewModel
    @State var isWizzardOpen = false
    @State var settingsSheetOpen: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    settingsSheetOpen.toggle()
                } label: {
                    Image(systemName: "gear")
                        .font(.title2)
                        .padding(.top, 5)
                }
                .tint(Color("FrDefault"))
            }
            IconView(name: "piggy-bank", color: Color("FrDefault"), size: 100)
            ScrollView {
                VStack {
                    if vm.budgets.isEmpty {
                        NoBudgetView()
                    } else {
                        ForEach(vm.budgets) { budget in
                            ContentSizeCardView {
                                HStack {
                                    Button {
                                        appState.selectBudget(budget)
                                    } label: {
                                        Text(budget.name ?? "Unknown")
                                            .font(.title2)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Menu {
                                        Button {
                                            vm.selectedBudget = budget
                                        } label: {
                                            Text("Edit")
                                        }
                                        Button(role: .destructive) {
                                            vm.deleteBudget(budget)
                                        } label: {
                                            Text("Delete")
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis").font(.title2)
                                            .padding(.leading, 10)
                                    }
                                }
                                .tint(.black)
                            }
                        }
                    }
                }
            }
            .padding(.top, 20)
            Button {
                isWizzardOpen.toggle()
            } label: {
                Text("Create")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("FrDefault"))
        }
        .padding(.horizontal, 10)
        .background(Color("BgDefault"))
        .onAppear {
            vm.loadBudgets()
        }
        .fullScreenCover(item: $vm.selectedBudget, onDismiss: onBudgetCreated) { budget in
            BudgetWizardView(vm: vm.budgetWizzardViewModel(), editMode: true)
        }
        .fullScreenCover(isPresented: $isWizzardOpen, onDismiss: onBudgetCreated) {
            BudgetWizardView(vm: vm.budgetWizzardViewModel(), editMode: false)
        }
        .fullScreenCover(isPresented: $settingsSheetOpen, onDismiss: onSettingsUpdated) {
            SettingsView()
        }
    }
    
    func onBudgetCreated() {
        vm.selectedBudget = nil
        vm.loadBudgets()
    }
    
    func onSettingsUpdated() {
        vm.loadBudgets()
    }
    
    @ViewBuilder
    func NoBudgetView() -> some View {
        VStack {
            Text("No budgets yet...")
                .font(.title)
        }
    }
    
}

#Preview("No budgets") {
    let bundle = ServiceBundle.preview
  
    let appState = AppState(budgetService: bundle.budgetService, settingsService: bundle.settingsService)
    return BudgetListView(vm:
                            BudgetListViewModel(budgetService: bundle.budgetService,
                                                dataService: bundle.dataService,
                                                notificationService: bundle.notificationService))
        .environmentObject(appState)
}

#Preview("List") {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget1 = BudgetEntity(context: dm.viewContext)
    budget1.id = UUID()
    budget1.name = "Budget 1"
    
    let budget2 = BudgetEntity(context: dm.viewContext)
    budget2.id = UUID()
    budget2.name = "Budget 2"
    
    do {
        try dm.sync()
        let appState = AppState(budgetService: bundle.budgetService, settingsService: bundle.settingsService)
        return BudgetListView(vm:
                                BudgetListViewModel(budgetService: bundle.budgetService,
                                                    dataService: bundle.dataService,
                                                    notificationService: bundle.notificationService))
            .environmentObject(appState)
            .serviceBundle(bundle)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
