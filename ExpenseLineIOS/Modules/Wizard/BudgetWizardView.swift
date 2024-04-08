//
//  BudgetWizardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.04.24.
//

import SwiftUI

enum WizzardPage: Int, Hashable {
    case intro = 0
    case base
    case income
    case fixed
    case expenses
    case summary
}

enum WizzardSheet: String, Identifiable {
    case incomeSource
    case fixedOutcome
    
    var id: String { rawValue }
    
}

struct NextButtonView: View {
    
    private let label: String
    private let action: () -> Void
    
    init(_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .font(.title2)
                .frame(maxWidth: .infinity)
                
        }
        .padding([.horizontal], 25)
        .buttonStyle(.borderedProminent)
        .tint(.green)
    }
    
}


struct BudgetWizardView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var currentPageIndex: WizzardPage = .fixed
    @StateObject var vm: BudgetWizardViewModel = BudgetWizardViewModel()
    
    @State var sheet: WizzardSheet?
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    previousPage()
                } label: {
                    Label("Back", systemImage: "chevron.backward")
                }
                .disabled(currentPageIndex == .base)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Label("Close", systemImage: "xmark")
                        .foregroundColor(Color.red)
                }
            }
            .padding([.horizontal], 10)
            TabView(selection: $currentPageIndex) {
                introPageView()
                    .tag(WizzardPage.intro)
                basePageView()
                    .tag(WizzardPage.base)
                incomePageView()
                    .tag(WizzardPage.income)
                fixedExpensesPageView()
                    .tag(WizzardPage.fixed)
                expensePageView()
                    .tag(WizzardPage.expenses)
                summaryPageView()
                    .tag(WizzardPage.summary)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            NextButtonView(nextButtonCaption()) {
                if currentPageIndex == .summary {
                    dismiss()
                } else {
                    nextPage()
                }
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .sheet(item: $sheet, onDismiss: onSheetClosed) { sheet in
            switch sheet {
            case .incomeSource:
                EditPlanCategorySheet(category: $vm.selectedIncomeSource, op: $vm.incomeSourceOp)
                    .presentationDetents([.medium])
            case .fixedOutcome:
                EditPlanCategorySheet(category: $vm.selectedFixedOutcome, op: $vm.fixedOutcomeOp)
                    .presentationDetents([.medium])
            }
        }
    }
    
    func nextButtonCaption() -> String {
        currentPageIndex == .summary ? "Create" : "Next"
    }
    
    func nextPage() {
        let nextValue = currentPageIndex.rawValue + 1
        if  nextValue <= WizzardPage.expenses.rawValue {
            currentPageIndex = WizzardPage(rawValue: nextValue) ?? .base
        }
    }
    
    func previousPage() {
        let previousValue = currentPageIndex.rawValue - 1
        if previousValue >= 0 {
            currentPageIndex = WizzardPage(rawValue: previousValue) ?? .base
        }
    }
    
    @ViewBuilder
    func introPageView() -> some View {
        VStack{
            Text("Creating a financial budget gives you control over your money, helps you achieve your financial goals, and reduces stress by providing a clear picture of your finances. It's a crucial tool for managing expenses, saving for the future, and ensuring financial security. Start budgeting today to take charge of your financial well-being and build a solid foundation for your future.")
                .font(.title3)
                .padding([.bottom], 10)
            Button {
                currentPageIndex = .summary
            } label: {
                Text("Skip")
            }
        }
        .padding([.horizontal], 15)
    }
    
    @ViewBuilder
    func basePageView() -> some View {
        Form {
            Section(header: Text("Basic")) {
                TextField("Name", text: $vm.name).padding([.top, .bottom], 5)
            }
            Section(header: Text("Type")) {
                Picker("Currency", selection: $vm.currency) {
                    ForEach(vm.getCurrencies(), id: \.self) { currency in
                        Text(currency)
                    }
                }
                Picker("Type", selection: $vm.type) {
                    ForEach(PlanType.allCases) { type in
                        Text("\(type)")
                    }
                }
            }
            Section(header: Text("Reminder")) {
                DatePicker("Daily reminder",
                           selection: $vm.dailyReminder,
                           displayedComponents: [.hourAndMinute])
            }
        }
    }
    
    @ViewBuilder
    func incomePageView() -> some View {
        VStack {
            Form {
                Section {
                    ForEach(vm.incomeSources) { income in
                        Button {
                            vm.selectIncomeSource(income, op: .edit)
                            sheet = .incomeSource
                        } label: {
                            HStack {
                                Image(systemName: income.iconName)
                                Text(income.name)
                                Spacer()
                                Text(income.amount, format: .number.rounded(increment: 0.01))
                                Text(vm.currency)
                            }
                            .foregroundColor(.black)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                vm.selectIncomeSource(income, op: .delete)
                                vm.performEditOps()
                            } label: {
                                Label("delete", systemImage: "trash.fill")
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                    HStack {
                        Button {
                            vm.newIncomeSource()
                            sheet = .incomeSource
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                } header: {
                    Text("Income Sources")
                }
            }
            Text("\(vm.getTotalIncomeAsString()) \(vm.currency)")
                .font(.title2)
        }
    }
    
    @ViewBuilder
    func fixedExpensesPageView() -> some View {
        VStack {
            Form {
                Section {
                    ForEach(vm.fixedOutcomes) { outcome in
                        Button {
                            vm.selectFixedOutcome(outcome, op: .edit)
                            sheet = .fixedOutcome
                        } label: {
                            HStack {
                                Image(systemName: outcome.iconName)
                                Text(outcome.name)
                                Spacer()
                                Text(outcome.amount, format: .number.rounded(increment: 0.01))
                                Text(vm.currency)
                            }
                            .foregroundColor(.black)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                vm.selectFixedOutcome(outcome, op: .delete)
                                vm.performEditOps()
                            } label: {
                                Label("delete", systemImage: "trash.fill")
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                    HStack {
                        Button {
                            vm.newFixedOutcome()
                            sheet = .fixedOutcome
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                } header: {
                    Text("Fixed outcomes")
                }
            }
            Text("\(vm.getTotalFixedOutcomeAsString()) \(vm.currency)")
                .font(.title2)
        }
    }
    
    @ViewBuilder
    func expensePageView() -> some View {
        VStack {
            Text("Scopes")
        }
    }
    
    @ViewBuilder
    func summaryPageView() -> some View {
        Text("Summary")
    }
    
    func onSheetClosed() {
        vm.performEditOps()
    }
    
}

#Preview {
    BudgetWizardView()
}
