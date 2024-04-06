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
    case scopes
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
    @State var currentPageIndex: WizzardPage = .income
    @StateObject var vm: BudgetWizardViewModel = BudgetWizardViewModel()
    
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
                initialPageView()
                    .tag(WizzardPage.base)
                incomePageView()
                    .tag(WizzardPage.income)
                scopeSelectorView()
                    .tag(WizzardPage.scopes)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            NextButtonView(nextButtonCaption()) {
                if currentPageIndex == .scopes {
                    dismiss()
                } else {
                    nextPage()
                }
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
    
    func nextButtonCaption() -> String {
        currentPageIndex == .scopes ? "Create" : "Next"
    }
    
    func nextPage() {
        let nextValue = currentPageIndex.rawValue + 1
        if  nextValue <= WizzardPage.scopes.rawValue {
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
    func initialPageView() -> some View {
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
        Form {
            Section {
                ForEach(vm.incomeSources) { income in
                    HStack {
                        Image(systemName: income.iconName)
                        Text(income.name)
                        Spacer()
                        Text(income.amount, format: .number.rounded(increment: 0.01))
                        Text(vm.currency)
                    }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            
                        } label: {
                            Label("delete", systemImage: "trash.fill")
                        }
                    }
                }
            } header: {
                Text("Income Sources")
            } footer: {
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func scopeSelectorView() -> some View {
        VStack {
            Text("Scopes")
        }
    }
    
}

#Preview {
    BudgetWizardView()
}
