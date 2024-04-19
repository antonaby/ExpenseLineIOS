//
//  BudgetWizardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.04.24.
//

import SwiftUI

enum WizzardPage: Int, Hashable {
    case base = 0
    case income
    case fixed
    case daily
    case summary
}

enum WizzardSheet: String, Identifiable {
    case incomeSource
    case fixedOutcome
    case dailyOutcome
    
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
    @State var currentPageIndex: WizzardPage = .base
    @StateObject var vm: BudgetWizardViewModel
    
    @State var sheet: WizzardSheet?
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    previousPage()
                } label: {
                    Label("Back", systemImage: "chevron.backward")
                }
                .disabled(currentPageIndex.rawValue == 0)
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
                MainWizardPageView(vm: vm)
                    .tag(WizzardPage.base)
                incomePageView()
                    .tag(WizzardPage.income)
                fixedExpensesPageView()
                    .tag(WizzardPage.fixed)
                dailyExpensesPageView()
                    .tag(WizzardPage.daily)
                summaryPageView()
                    .tag(WizzardPage.summary)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            NextButtonView(nextButtonCaption()) {
                if currentPageIndex == .summary {
                    vm.createBudget()
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
            case .dailyOutcome:
                EditDailyPlanCategorySheet(category: $vm.selectedDailyOutcome, op: $vm.dailyOutcomeOp)
                    .presentationDetents([.medium])
            }
        }
    }
    
    func nextButtonCaption() -> String {
        currentPageIndex == .summary ? "Create" : "Next"
    }
    
    func nextPage() {
        let nextValue = currentPageIndex.rawValue + 1
        if  nextValue <= WizzardPage.summary.rawValue {
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
            HStack {
                Text(vm.getTotalIncome(), format: .number.rounded(increment: 0.01))
                Text(vm.currency)
            }
            .font(.title2)
        }
    }
    
    @ViewBuilder
    func fixedExpensesPageView() -> some View {
        VStack {
            HStack {
                Text(vm.getRemainingBudget(), format: .number.rounded(increment: 0.01))
                Text(vm.currency)
            }
            .font(.title3)
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
            HStack {
                Text(vm.getTotalFixedOutcome(), format: .number.rounded(increment: 0.01))
                Text(vm.currency)
            }
            .font(.title2)
        }
    }
    
    @ViewBuilder
    func dailyExpensesPageView() -> some View {
        VStack {
            HStack {
                Text(vm.getRemainingBudget(), format: .number.rounded(increment: 0.01))
                Text(vm.currency)
            }
            .font(.title3)
            Form {
                Section {
                    ForEach(vm.dailyOutcomes) { outcome in
                        Button {
                            vm.selectDailyOutcome(outcome, op: .edit)
                            sheet = .dailyOutcome
                        } label: {
                            VStack {
                                HStack {
                                    Image(systemName: outcome.iconName)
                                    Text(outcome.name)
                                    Spacer()
                                    Text(outcome.percent, format: .percent)
                                }
                                HStack {
                                    Text(vm.getAmountForDailyCatedory(outcome), format: .number.rounded(increment: 0.01))
                                    Text(vm.currency)
                                }
                                .font(.caption)
                            }
                            .foregroundColor(.black)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                vm.selectDailyOutcome(outcome, op: .delete)
                                vm.performEditOps()
                            } label: {
                                Label("delete", systemImage: "trash.fill")
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                    HStack {
                        Button {
                            vm.newDailyOutcome()
                            sheet = .dailyOutcome
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                } header: {
                    Text("Daily outcomes")
                }
            }
            HStack {
                Text(vm.getTotalDailyOutcome(), format: .number.rounded(increment: 0.01))
                Text(vm.currency)
            }
            .font(.title2)
        }
    }
    
    @ViewBuilder
    func summaryPageView() -> some View {
        VStack {
            HStack {
                Text("Income:")
                Text(vm.getTotalIncome(), format: .number.rounded(increment: 0.01))
                Text(vm.currency)
            }
            HStack {
                Text("Fixed Expenses:")
                Text(vm.getTotalFixedOutcome(), format: .number.rounded(increment: 0.01))
                Text(vm.currency)
            }
            HStack {
                Text("Daily:")
                Text(vm.getTotalDailyOutcome(), format: .number.rounded(increment: 0.01))
                Text(vm.currency)
            }
            HStack {
                Text("Savings:")
                Text(vm.getRemainingBudget(), format: .number.rounded(increment: 0.01))
                Text(vm.currency)
            }
        }
        .font(.title3)
    }
    
    func onSheetClosed() {
        vm.performEditOps()
    }
    
}

#Preview("New Budget") {
    do {
        let vm = try DependencyResolver.preview.budgetWizzardViewModel()
        return MainWizardPageView(vm: vm)
    } catch {
        return Text("Something went wrong \(error)")
    }
}

#Preview("Edit Budget") {
    do {
        let vm = try DependencyResolver.preview.budgetWizzardViewModel()
        return MainWizardPageView(vm: vm)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
