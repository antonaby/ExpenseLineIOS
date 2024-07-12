//
//  MainWizardPageView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.04.24.
//

import SwiftUI

struct MainWizardPageView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    
    @ObservedObject var vm: BudgetWizardViewModel
    @State var currencySheetOpen: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                FlexibleCardView {
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "pencil")
                                .frame(width: 30)
                                .foregroundColor(Color.appLink)
                            TextField("Name", text: $vm.name)
                        }
                        Divider()
                        Button {
                            currencySheetOpen.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "banknote")
                                    .frame(width: 30)
                                    .foregroundColor(Color.appLink)
                                Text("Currency")
                                Spacer()
                                Text(vm.currency.code)
                                    .bold()
                            }
                            .foregroundColor(Color.appCardTextColor)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .onAppear {
            appState.showHelpPage(for: .mainWizard, firstTime: true)
        }
        .background(Color.appBackground)
        .sheet(isPresented: $currencySheetOpen) {
            CurrencySelectorSheet(currency: $vm.currency, vm: CurrencySelectorSheetViewModel(dataService: dataService))
                .presentationDetents([.large, .medium])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(appState.colorScheme)
        }
    }
}

#Preview {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.name = "Preview"
    budget.currency = "en_US"
    
    return MainWizardPageView(
        vm: BudgetWizardViewModel(
            budget, 
            budgetService: bundle.budgetService,
            dataService: bundle.dataService,
            notificationService: bundle.notificationService,
            analyticsService: bundle.analyticsService
        ))
    .serviceBundle(bundle)
    .environmentObject(AppState(bundle: bundle))
}
