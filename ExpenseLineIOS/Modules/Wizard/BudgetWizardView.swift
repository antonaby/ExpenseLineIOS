//
//  BudgetWizardView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.04.24.
//

import SwiftUI

enum WizzardPage: Int, Identifiable, CaseIterable {
    case base = 0
    case outcome
    case summary
    
    var id: Self { self }
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
                ToolButton(icon: "x.circle", color: .red) {
                    vm.rollback()
                    dismiss()
                }
                .font(.title2)
            }
            .padding([.horizontal], 10)
            TabView(selection: $currentPage) {
                MainWizardPageView(vm: vm)
                    .tag(WizzardPage.base)
                CategoryListWizardView(vm: vm, types: [.outcomeFixed, .outcomePercent])
                    .tag(WizzardPage.outcome)
                SummaryWizardPage()
                    .tag(WizzardPage.summary)
            }
            HStack(spacing: 20) {
                ForEach(WizzardPage.allCases) { page in
                    PageIconView(page)
                }
            }
            .padding(.bottom, 10)
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
            EditCategorySheet(title: "Save",
                              vm: EditPlanCategorySheetViewModel(category, currencySymbol: vm.currency))
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
        .onDisappear {
            vm.cancelAll()
        }
    }
    
    @ViewBuilder
    func PageIconView(_ page: WizzardPage) -> some View {
        Button {
            currentPage = page
        } label: {
            FlexibleCardView(color: currentPage == page ? .green : .white) {
                Image(systemName: getIconForPage(page))
                    .font(.title2)
                    .foregroundColor(currentPage == page ? .white : .black)
            }
            .frame(width: 50, height: 50)
        }
    }
    
    func getIconForPage(_ page: WizzardPage) -> String {
        switch page {
        case .base:
            return "case"
        case .outcome:
            return "list.bullet"
        case .summary:
            return "checkmark"
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
            .environmentObject(DependencyResolver.preview)
    } catch {
        return Text("Something went wrong \(error)")
    }
}

#Preview("Edit Budget") {
    do {
        let vm = try DependencyResolver.preview.budgetWizzardViewModel()
        return BudgetWizardView(vm: vm)
            .environmentObject(DependencyResolver.preview)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
