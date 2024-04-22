//
//  MainWizardPageView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 19.04.24.
//

import SwiftUI
import Combine

class MainWizardPageViewModel: ObservableObject {
    
    @Published var name: String
    @Published var currency: String
    @Published var type: PlanType
    @Published var periodStartsAt: Date
    @Published var dailyReminder: Date
    
    @Published var isFormValid: Bool = false
    
    private var budget: BudgetEntity
    private var cancellables = Set<AnyCancellable>()
    
    init(_ budget: BudgetEntity) {
        self.budget = budget
        
        self.name = budget.name ?? "My Budget"
        self.currency = budget.currency ?? "EUR"
        self.type = budget.planTypeValue 
        
        // TODO: add to entity
        self.dailyReminder = Date()
        let periodComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        self.periodStartsAt = Calendar.current.date(from: periodComponents)!
        
        isValid.sink { [weak self]  isValid in
            guard let self = self else { return }
            self.isFormValid = isValid
        }
        .store(in: &cancellables)
        
    }
    
    func getCurrencies() -> [String] {
        return ["USD", "EUR", "RUB", "AMD"]
    }
    
    func getDateRange() -> ClosedRange<Date> {
        let periodComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        let firstDay = Calendar.current.date(from: periodComponents)!
        
        return firstDay ... Date()
    }
    
    // TODO: cancel all
    func cancelAll() {
        for c in cancellables {
            c.cancel()
        }
    }
    
    func save() {
        budget.name = name
        budget.currency = currency
        budget.planTypeValue = type
        
        // TODO: save with CoreData
    }
    
}

extension MainWizardPageViewModel {
    
    var isNameValid: AnyPublisher<Bool, Never> {
        $name.debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { name in
                name.count > 0
            }
            .eraseToAnyPublisher()
    }
    
    var isCurrencyValid: AnyPublisher<Bool, Never> {
        $currency.debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { currency in
                currency.count == 3
            }
            .eraseToAnyPublisher()
    }
    
    var isValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isNameValid, isCurrencyValid)
            .map { isNameValid, isCurrencyValid in
                isNameValid && isCurrencyValid
            }
            .eraseToAnyPublisher()
    }
    
}

struct MainWizardPageView: View {
    
    @ObservedObject var vm: MainWizardPageViewModel
    
    var body: some View {
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
                DatePicker("Period Starts at",
                           selection: $vm.periodStartsAt,
                           in: vm.getDateRange(),
                           displayedComponents: [.date])
            }
            Section(header: Text("Reminder")) {
                DatePicker("Daily reminder",
                           selection: $vm.dailyReminder,
                           displayedComponents: [.hourAndMinute])
            }
        }
    }
}

#Preview {
    let budget = BudgetEntity(context: DependencyResolver.preview.databaseManager().viewContext)
    budget.name = "Preview"
    budget.currency = "USD"
    budget.planTypeValue = .mountly
    
    return MainWizardPageView(vm: MainWizardPageViewModel(budget))
}
