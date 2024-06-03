//
//  BudgetOverviewView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 11.04.24.
//

import SwiftUI

enum SpengingsType: Int, CaseIterable, Identifiable {
    
    case overall = 0
    case fixed = 1
    case flexible = 2
    
    var id: Self { self }
    
}

struct BudgetOverviewView: View {
    
    @EnvironmentObject var setting: SettingsService
    @StateObject var vm: BudgetOverviewViewModel
    
    @State var spendings: SpengingsType = .overall
    
    var loadStats: Bool = true
    
    var body: some View {
        VStack {
            CirclularBudgetProgressView(
                progress: [
                    getTotalSpent(),
                    getFixedSpent(),
                    getPercentSpent()
                ],
                colors: [.green, .purple, .orange],
                selected: spendings.rawValue,
                gap: setting.getBoolPreference(for: SettingsService.GAPS_IN_CIRCLE)
            ) {
                VStack {
                    Text(vm.parent.formatPercent(getTotalSpentDecimal()))
                        .font(.title)
                        .bold()
                    Text("Spent")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            .frame(width: 250, height: 250)
            .padding()
            TabView(selection: $spendings) {
                SpendingsView(
                    title: "Spendings",
                    firstColor: .green,
                    secondColor: .green.opacity(0.3),
                    left: { AmountView(vm.totalOutcome) {
                        vm.totalPlannedFixedOutcome + vm.totalPlannedPercentOutcomeAmount - $0 < 0
                    }},
                    right: { AmountView(vm.totalBudgetLeft) {
                        $0 < 0
                    }
                    })
                .tag(SpengingsType.overall)
                SpendingsView(
                    title: "Fixed",
                    firstColor: .purple,
                    secondColor: .purple.opacity(0.3),
                    left: { AmountView(vm.totalFixedOutcome) {
                        vm.totalPlannedFixedOutcome - $0 < 0
                    }},
                    right: { AmountView(vm.totalFixedBudgetLeft) {
                        $0 < 0
                    }
                    })
                .tag(SpengingsType.fixed)
                SpendingsView(
                    title: "Flexible",
                    firstColor: .orange,
                    secondColor: .orange.opacity(0.3),
                    left: { AmountView(vm.totalPercentOutcome) {
                        vm.totalPlannedPercentOutcomeAmount - $0 < 0
                    }},
                    right: { AmountView(vm.totalFlexibleBudgetLeft) {
                        $0 < 0
                    }
                    })
                .tag(SpengingsType.flexible)
            }
            .frame(height: 100)
            .tabViewStyle(.page(indexDisplayMode: .never))
            SpenginsView()
        }
        .padding([.horizontal, .top], 15)
        .onAppear {
            vm.subscribe()
            if loadStats {
                vm.loadAmounts()
            }
        }
        .onDisappear {
            vm.cancelAll()
        }
        
    }
    
    @ViewBuilder
    func AmountView(_ amount: Decimal, isSpent: (Decimal) -> Bool) -> some View {
        Text(vm.parent.formatAmount(amount))
            .foregroundColor(isSpent(amount) ? .red : .black)
            .font(.title2)
    }
    
    @ViewBuilder
    func SpendingsView(
        title: String,
        firstColor: Color,
        secondColor: Color,
        @ViewBuilder left: () -> some View,
        @ViewBuilder right: () -> some View
    ) -> some View {
        VStack {
            Text(title)
            HStack {
                RoundedRectangle(cornerRadius: 3, style: .circular)
                    .foregroundColor(firstColor)
                    .frame(width: 15, height: 15)
                left()
                RoundedRectangle(cornerRadius: 3, style: .circular)
                    .foregroundColor(secondColor)
                    .frame(width: 15, height: 15)
                right()
            }
        }
    }
    
    @ViewBuilder
    func SpenginsView() -> some View {
        HStack {
            ForEach(SpengingsType.allCases) { type in
                Button {
                    spendings = type
                } label: {
                    FlexibleCardView(cornerRadius: 7, color: spendings == type ? .green : .white) {
                        Image(systemName: getIconForPage(type))
                            .foregroundColor(spendings == type ? .white : .black)
                            .font(.caption)
                            .bold()
                    }
                    .frame(width: 30, height: 30)
                }
            }
        }
    }
    
    func getIconForPage(_ type: SpengingsType) -> String {
        switch type {
        case .overall:
            return "arrow.down"
        case .fixed:
            return "house"
        case .flexible:
            return "takeoutbag.and.cup.and.straw"
        }
    }
    
    func getTotalSpentDecimal() -> Decimal {
        if vm.parent.totalPlannedIncome <= 0 {
            return 0
        }
        if vm.totalOutcome <= 0 {
            return 0
        }
        
        return vm.totalOutcome / vm.parent.totalPlannedIncome
    }
    
    func getTotalSpent() -> Double {
        return Double(truncating: getTotalSpentDecimal() as NSNumber)
    }
    
    func getFixedSpent() -> Double {
        if vm.totalPlannedFixedOutcome <= 0 {
            return 0
        }
        if vm.totalFixedOutcome <= 0 {
            return 0
        }
        
        let total = vm.totalFixedOutcome / vm.totalPlannedFixedOutcome
        return Double(truncating: total as NSNumber)
    }
    
    func getPercentSpent() -> Double {
        if vm.totalPlannedPercentOutcomeAmount <= 0 {
            return 0
        }
        if vm.totalPercentOutcome <= 0 {
            return 0
        }
        
        let total = vm.totalPercentOutcome / vm.totalPlannedPercentOutcomeAmount
        return Double(truncating: total as NSNumber)
    }
}

#Preview("OK") {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    budget.currency = "en_US"
   
    do {
        let plannedCategory = bundle.budgetService.newCategoryEntity(budget)
        plannedCategory.typeValue = .income
        plannedCategory.amountDecimal = 3500
        
        let parent = BudgetViewModel(
            budget: budget,
            period: try bundle.budgetService.getOrCreateLastPeriod(budget),
            budgetService: bundle.budgetService, dataService: bundle.dataService
        )
        
        let vm = BudgetOverviewViewModel(parent: parent, budgetService: bundle.budgetService)
        
        vm.totalPlannedFixedOutcome = 600
        vm.totalPlannedPercentOutcomeAmount = 1500
        vm.totalOutcome = 2000
        vm.totalBudgetLeft = 1500
        vm.totalFixedOutcome = 450
        vm.totalPercentOutcome = 1000
        vm.totalFixedBudgetLeft = 1000
        vm.totalFlexibleBudgetLeft = 500
        
        bundle.settingsService.setBoolPreference(for: SettingsService.GAPS_IN_CIRCLE, value: false)
        
        return BudgetOverviewView(vm: vm, loadStats: false)
            .serviceBundle(bundle)
    } catch {
        return Text("Something went wrong \(error)")
    }
}

#Preview("Almost") {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    budget.currency = "en_US"
   
    do {
        let plannedCategory = bundle.budgetService.newCategoryEntity(budget)
        plannedCategory.typeValue = .income
        plannedCategory.amountDecimal = 3500
        
        let parent = BudgetViewModel(
            budget: budget,
            period: try bundle.budgetService.getOrCreateLastPeriod(budget),
            budgetService: bundle.budgetService, dataService: bundle.dataService
        )
        
        let vm = BudgetOverviewViewModel(parent: parent, budgetService: bundle.budgetService)
        
        vm.totalPlannedFixedOutcome = 600
        vm.totalPlannedPercentOutcomeAmount = 1500
        vm.totalOutcome = 2000
        vm.totalBudgetLeft = 1500
        vm.totalFixedOutcome = 450
        vm.totalPercentOutcome = 1550
        vm.totalFixedBudgetLeft = 1000
        vm.totalFlexibleBudgetLeft = 500
        
        bundle.settingsService.setBoolPreference(for: SettingsService.GAPS_IN_CIRCLE, value: true)
        
        return BudgetOverviewView(vm: vm, loadStats: false)
            .serviceBundle(bundle)
    } catch {
        return Text("Something went wrong \(error)")
    }
}

#Preview("Spent") {
    let bundle = ServiceBundle.preview
    let dm = bundle.databaseManager
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
    budget.currency = "en_US"
   
    do {
        let plannedCategory = bundle.budgetService.newCategoryEntity(budget)
        plannedCategory.typeValue = .income
        plannedCategory.amountDecimal = 3500
        
        let parent = BudgetViewModel(
            budget: budget,
            period: try bundle.budgetService.getOrCreateLastPeriod(budget),
            budgetService: bundle.budgetService, dataService: bundle.dataService
        )
        
        let vm = BudgetOverviewViewModel(parent: parent, budgetService: bundle.budgetService)
        
        vm.totalPlannedFixedOutcome = 600
        vm.totalPlannedPercentOutcomeAmount = 1500
        vm.totalOutcome = 4000
        vm.totalBudgetLeft = -500
        vm.totalFixedOutcome = 650
        vm.totalPercentOutcome = 1550
        vm.totalFixedBudgetLeft = 1000
        vm.totalFlexibleBudgetLeft = 500
        
        bundle.settingsService.setBoolPreference(for: SettingsService.GAPS_IN_CIRCLE, value: false)
        
        return BudgetOverviewView(vm: vm, loadStats: false)
            .serviceBundle(bundle)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
