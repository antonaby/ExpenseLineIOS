//
//  BudgetWizardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.04.24.
//

import SwiftUI

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
                    vm.rollback()
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
                CategoryWizardPageView(vm: vm, name: "Income", page: .income, type: .income)
                    .tag(WizzardPage.income)
                CategoryWizardPageView(vm: vm, name: "Fixed Outcome", page: .fixed, type: .outcomeFixed)
                    .tag(WizzardPage.fixed)
                CategoryWizardPageView(vm: vm, name: "Daily Spendings", page: .dynamic, type: .outcomePercent)
                    .tag(WizzardPage.dynamic)
                SummaryWizardPage()
                    .tag(WizzardPage.summary)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            WizzardNextButton(nextButtonCaption()) {
                if currentPage == .summary {
                    vm.save()
                    dismiss()
                } else {
                    nextPage()
                }
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .sheet(item: $vm.selectedCategory) { category in
            EditCategorySheet(title: "Save", vm: EditPlanCategorySheetViewModel(category, currency: vm.currency))
                .onUpdateCategory { category in
                    vm.updateCategory(category)
                }
                .onDeleteCategory { category in
                    vm.deleteCategory(category)
                }
                .onDismissCategory { category in
                    vm.dismissCategory(category)
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
