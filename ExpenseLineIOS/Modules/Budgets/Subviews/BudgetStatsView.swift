//
//  BudgetStatsView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 11.04.24.
//

import SwiftUI
import Charts


struct BudgetStatsView: View {
    
    @ObservedObject var vm: BudgetViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                FlexibleCardView {
                    VStack {
                        Text("Spending day")
                            .bold()
                        Chart(vm.daySpendings) { spendings in
                            LineMark(
                                x: .value("Day", spendings.date, unit: .day),
                                y: .value("Amount", spendings.value)
                            )
                            .symbol(.circle)
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(.green)
                            AreaMark(
                                x: .value("Day", spendings.date, unit: .day),
                                y: .value("Amount", spendings.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Gradient(colors: [Color.green, Color.green.opacity(0.1)]))
                        }
                        .frame(height: 150)
                    }
                }
                FlexibleCardView {
                    VStack {
                        Text("Spendings by month")
                            .bold()
                        Chart {
                            ForEach(vm.monthSpendings) { spendings in
                                BarMark(
                                    x: .value("Month", spendings.date, unit: .month),
                                    y: .value("Amount", spendings.value)
                                )
                                .cornerRadius(10)
                            }
                        }
                        .frame(height: 150)
                    }
                }
            }
        }
        .padding([.horizontal, .top], 15)
        .background(Color(uiColor: .secondarySystemBackground))
        .onAppear {
            vm.loadDaySpendings()
            vm.loadMonthSpendings()
        }
    }
}

#Preview {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    budget.currency = "en_US"
    
    let vm = BudgetViewModel(
        budget: budget, budgetService: bundle.budgetService, dataService: bundle.dataService
    )
    
    return BudgetStatsView(vm: vm)
}
