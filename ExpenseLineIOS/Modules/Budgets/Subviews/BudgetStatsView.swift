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
    
    var loadStats: Bool = true
    
    var body: some View {
        ScrollView {
            VStack {
                FlexibleCardView {
                    VStack {
                        Text("Spending by day")
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
                                .foregroundStyle(.green)
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
            if loadStats {
                vm.loadData(for: .stats)
            }
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
    
    do {
        let vm = BudgetViewModel(
            budget: budget,
            period: try bundle.budgetService.getOrCreateLastPeriod(budget),
            budgetService: bundle.budgetService, dataService: bundle.dataService
        )
        
        vm.daySpendings = [
            SpenginsStat(id: 0, date: Date(), value: 10),
            SpenginsStat(id: 1, date: Date().plusDay(1), value: 20),
            SpenginsStat(id: 2, date: Date().plusDay(2), value: 10),
            SpenginsStat(id: 3, date: Date().plusDay(3), value: 40),
            SpenginsStat(id: 4, date: Date().plusDay(4), value: 100),
            SpenginsStat(id: 5, date: Date().plusDay(5), value: 20),
            SpenginsStat(id: 6, date: Date().plusDay(6), value: 15),
            SpenginsStat(id: 7, date: Date().plusDay(7), value: 0),
            SpenginsStat(id: 8, date: Date().plusDay(8), value: 20),
            SpenginsStat(id: 9, date: Date().plusDay(9), value: 80),
        ]
        
        vm.monthSpendings = [
            SpenginsStat(id: 0, date: Date(), value: 10),
            SpenginsStat(id: 1, date: Date().plusMonth(-1), value: 200),
            SpenginsStat(id: 2, date: Date().plusMonth(-2), value: 100),
            SpenginsStat(id: 3, date: Date().plusMonth(-3), value: 400),
            SpenginsStat(id: 4, date: Date().plusMonth(-4), value: 1000),
            SpenginsStat(id: 5, date: Date().plusMonth(-5), value: 200),
            SpenginsStat(id: 6, date: Date().plusMonth(-6), value: 150),
            SpenginsStat(id: 7, date: Date().plusMonth(-7), value: 10),
            SpenginsStat(id: 8, date: Date().plusMonth(-8), value: 200),
            SpenginsStat(id: 9, date: Date().plusMonth(-9), value: 800),
        ]
        
        return BudgetStatsView(vm: vm, loadStats: false)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
