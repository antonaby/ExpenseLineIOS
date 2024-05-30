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
    
    @State var showDatePicker: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                FlexibleCardView {
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "pencil")
                                .frame(width: 30)
                            TextField("Name", text: $vm.name)
                        }
                        Divider()
                        Button {
                            currencySheetOpen.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "banknote")
                                    .frame(width: 30)
                                Text("Currency")
                                Spacer()
                                Text(vm.currency.code)
                                    .bold()
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
                Text("Notification")
                    .modifier(FormTitleViewModifier.modifier)
                FlexibleCardView {
                    VStack(spacing: 10) {
                        Toggle(isOn: $vm.dailyReminderEnabled) {
                            HStack {
                                Image(systemName: "bell")
                                    .frame(width: 25)
                                Text("Daily Reminder")
                            }
                        }
                        .onChange(of: vm.dailyReminderEnabled) { value in
                            withAnimation {
                                showDatePicker = value
                            }
                        }
                        if showDatePicker {
                            HStack {
                                Image(systemName: "clock")
                                    .frame(width: 25)
                                DatePicker("Notify me at",
                                           selection: $vm.dailyReminderAt,
                                           displayedComponents: [.hourAndMinute])
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            showDatePicker = vm.dailyReminderEnabled
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
            dataService: bundle.dataService,
            notificationService: bundle.notificationService
        ))
    .serviceBundle(bundle)
}
