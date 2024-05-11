//
//  MainWizardPageView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.04.24.
//

import SwiftUI

struct MainWizardPageView: View {
    
    @ObservedObject var vm: BudgetWizardViewModel
    @State var currencySheetOpen: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Budget")
                    .modifier(FormTitleViewModifier.modifier)
                Text("Let's add a **name** and choose **currency** of out budget")
                    .modifier(FormTipViewModifier.modifier)
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
                Text("**A first day** is when a new budget period starts")
                    .modifier(FormTipViewModifier.modifier)
                Text("**Daily reminded** don't let you forget add today's transactions")
                    .modifier(FormTipViewModifier.modifier)
                FlexibleCardView {
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "calendar")
                            DatePicker("First Day",
                                       selection: $vm.periodStartsAt,
                                       in: Date().dateRangeFromBegingOfMonth(),
                                       displayedComponents: [.date])
                        }
                        Divider()
                        HStack {
                            Image(systemName: "clock")
                            DatePicker("Daily Reminder",
                                       selection: $vm.dailyReminderAt,
                                       displayedComponents: [.hourAndMinute])
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 10)
        .background(Color(uiColor: .secondarySystemBackground))
        .sheet(isPresented: $currencySheetOpen) {
            CurrencySelectorSheet(currency: $vm.currency)
                .presentationDetents([.large, .medium])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    let dm = DependencyResolver.preview.databaseManager()
    let budget = BudgetEntity(context: dm.viewContext)
    budget.name = "Preview"
    budget.currency = "en_US"
    budget.planTypeValue = .mountly
    
    return MainWizardPageView(
        vm: BudgetWizardViewModel(
            budget, 
            budgetService: DependencyResolver.preview.budgetService(),
            dataService: DependencyResolver.preview.dataService()
        ))
        .environmentObject(DependencyResolver.preview)
}
