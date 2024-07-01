//
//  PeriodListView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 13.05.24.
//

import SwiftUI

class PeriodListViewModel: ObservableObject {
    
    @Published var periods: [PeriodEntity] = []
    
    private let budget: BudgetEntity
    private let budgetService: BudgetService
    
    init(budget: BudgetEntity, budgetService: BudgetService) {
        self.budget = budget
        self.budgetService = budgetService
    }
    
    func loadPeriods() {
        do {
            periods = try budgetService.getBudgetPeriods(budget)
        } catch {
            // TODO: handle error
            print("Something went wrong \(error)")
        }
    }
    
}

struct PeriodListView: View {
    
    @EnvironmentObject var formatters: FormattersHolder
    
    @Environment(\.dismiss) var dismiss
    @Binding var selected: PeriodEntity
    @StateObject var vm: PeriodListViewModel
    
    var body: some View {
        VStack {
            List(vm.periods) { period in
                Button {
                    selected = period
                    dismiss()
                } label: {
                    Text(formatters.formatMonth(period.startsAt))
                        .tint(.black)
                }
                .foregroundStyle(Color.appCardTextColor)
            }
            .background(Color.appBackground)
            .scrollContentBackground(.hidden)
        }
        .onAppear {
            vm.loadPeriods()
        }
    }
}

#Preview {
    let bundle = ServiceBundle.preview
    
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    
    let currentDate = Date()
    
    let period1 = PeriodEntity(context: dm.viewContext)
    period1.id = UUID()
    period1.startsAt = currentDate.firstDayOfMonth()
    period1.endsAt = currentDate.lastDayOfMonth()
    period1.budget = budget
    
    let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
    let period2 = PeriodEntity(context: dm.viewContext)
    period2.id = UUID()
    period2.startsAt = previousMonth.firstDayOfMonth()
    period2.endsAt = previousMonth.lastDayOfMonth()
    period2.budget = budget
    
    let previousMonth2 = Calendar.current.date(byAdding: .month, value: -2, to: currentDate)!
    let period3 = PeriodEntity(context: dm.viewContext)
    period3.id = UUID()
    period3.startsAt = previousMonth2.firstDayOfMonth()
    period3.endsAt = previousMonth2.lastDayOfMonth()
    period3.budget = budget
    
    return PeriodListView(selected: .constant(period1),
                          vm: PeriodListViewModel(budget: budget, budgetService: bundle.budgetService))
    .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
}
