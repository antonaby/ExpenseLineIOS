//
//  BudgetWizardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.04.24.
//

import SwiftUI

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
    @State var currentPage: WizzardPage = .base

    @StateObject var vm: BudgetWizardViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    previousPage()
                } label: {
                    Label("Back", systemImage: "chevron.backward")
                }
                .disabled(currentPage.rawValue == 0)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Label("Close", systemImage: "xmark")
                        .foregroundColor(Color.red)
                }
            }
            .padding([.horizontal], 10)
            TabView(selection: $currentPage) {
                MainWizardPageView(vm: vm)
                    .tag(WizzardPage.base)
                CategoryWizardPageView(vm: vm, page: .income, type: .income)
                    .tag(WizzardPage.income)
                CategoryWizardPageView(vm: vm, page: .fixed, type: .outcomeFixed)
                    .tag(WizzardPage.fixed)
                CategoryWizardPageView(vm: vm, page: .dynamic, type: .outcomePercent)
                    .tag(WizzardPage.dynamic)
                /*
                summaryPageView()
                    .tag(WizzardPage.summary)
                 */
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            NextButtonView(nextButtonCaption()) {
                if currentPage == .summary {
                    dismiss()
                } else {
                    nextPage()
                }
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .sheet(item: $vm.selectedCategory) { category in
            EditPlanCategorySheet(vm: EditPlanCategorySheetViewModel(category), op: vm.op)
                .onUpdateCategory { category in
                    vm.updateCategory(category)
                }
                .onDeleteCategory { category in
                    vm.deleteCategory(category)
                }
                .presentationDetents([.medium])
        }
    }
    
    func nextButtonCaption() -> String {
        currentPage == .summary ? "Create" : "Next"
    }
    
    func nextPage() {
        let nextValue = currentPage.rawValue + 1
        if  nextValue <= WizzardPage.summary.rawValue {
            currentPage = WizzardPage(rawValue: nextValue) ?? .base
        }
    }
    
    func previousPage() {
        let previousValue = currentPage.rawValue - 1
        if previousValue >= 0 {
            currentPage = WizzardPage(rawValue: previousValue) ?? .base
        }
    }
    
    /*
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
    }*/
    
}

#Preview("New Budget") {
    do {
        let vm = try DependencyResolver.preview.budgetWizzardViewModel()
        return BudgetWizardView(vm: vm)
    } catch {
        return Text("Something went wrong \(error)")
    }
}

#Preview("Edit Budget") {
    do {
        let vm = try DependencyResolver.preview.budgetWizzardViewModel()
        return BudgetWizardView(vm: vm)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
