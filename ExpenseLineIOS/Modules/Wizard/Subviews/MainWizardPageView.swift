//
//  MainWizardPageView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.04.24.
//

import SwiftUI

struct MainWizardPageView: View {
    
    @EnvironmentObject var dataService: DataService
    
    @ObservedObject var vm: BudgetWizardViewModel
    @State var currencySheetOpen: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                FlexibleCardView {
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "case")
                            TextField("Name", text: $vm.name)
                        }
                        Divider()
                        Button {
                            currencySheetOpen.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "banknote")
                                Text("Currency")
                                Spacer()
                                Text(vm.currency.code)
                                    .bold()
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
                Text("Preferences")
                    .modifier(FormTitleViewModifier.modifier)
                FlexibleCardView {
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "clock")
                            DatePicker("Daily Reminder",
                                       selection: $vm.dailyReminderAt,
                                       displayedComponents: [.hourAndMinute])
                        }
                    }
                }
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .sheet(isPresented: $currencySheetOpen) {
            CurrencySelectorSheet(currency: $vm.currency, vm: CurrencySelectorSheetViewModel(dataService: dataService))
                .presentationDetents([.large, .medium])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.name = "Preview"
    budget.currency = "en_US"
    budget.planTypeValue = .mountly
    
    return MainWizardPageView(
        vm: BudgetWizardViewModel(
            budget, 
            budgetService: bundle.budgetService,
            dataService: bundle.dataService
        ))
    .serviceBundle(bundle)
}
