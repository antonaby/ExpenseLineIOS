//
//  BudgetStatsView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 11.04.24.
//

import SwiftUI
import Charts


struct BudgetStatsView: View {
    
    @EnvironmentObject var analyticsService: AnalyticsService
    
    @StateObject var vm: BudgetStatsViewModel
    
    var loadStats: Bool = true
    
    var body: some View {
        ScrollView {
            VStack {
                FlexibleCardView {
                    VStack {
                        Text("Expenses by Day")
                            .bold()
                        Chart(vm.daySpendings) { spendings in
                            LineMark(
                                x: .value("Day", spendings.date, unit: .day),
                                y: .value("Amount", spendings.value)
                            )
                            .symbol(.circle)
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Color.appLink)
                            AreaMark(
                                x: .value("Day", spendings.date, unit: .day),
                                y: .value("Amount", spendings.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Gradient(colors: [Color.appLink, Color.appLink.opacity(0.1)]))
                        }
                        .frame(height: 150)
                    }
                }
                FlexibleCardView {
                    VStack {
                        Text("Expenses by Month")
                            .bold()
                        Chart {
                            ForEach(vm.monthSpendings) { spendings in
                                BarMark(
                                    x: .value("Month", spendings.date, unit: .month),
                                    y: .value("Amount", spendings.value)
                                )
                                .cornerRadius(10)
                                .foregroundStyle(Color.appLink)
                            }
                        }
                        .frame(height: 150)
                    }
                }
            }
        }
        .padding(.top, 15)
        .padding(.horizontal, 20)
        .background(Color.appBackground)
        .onAppear {
            vm.subscribe()
            if loadStats {
                vm.loadSpendings()
            }
            analyticsService.logEvent(name: AnalyticsService.BUDGET_OPEN_STATS)
        }
        .onDisappear {
            vm.cancelAll()
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
        let parent = BudgetViewModel(
            budget: budget,
            period: try bundle.budgetService.getOrCreateLastPeriod(budget),
            budgetService: bundle.budgetService, dataService: bundle.dataService,
            analyticsService: bundle.analyticsService
        )
        
        let vm = BudgetStatsViewModel(parent: parent,
                                      budgetService: bundle.budgetService,
                                      analyticsService: bundle.analyticsService)
        
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
            .serviceBundle(bundle)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
