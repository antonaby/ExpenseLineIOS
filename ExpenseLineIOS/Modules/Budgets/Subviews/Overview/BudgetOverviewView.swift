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

struct SliderView: View {
    
    @Environment(\.isEnabled) var isEnabled
    
    let icon: String
    let action: () -> Void
    
    init(icon: String, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isEnabled ? Color.appLink : Color.appLinkInactive)
        }
    }

}

struct BudgetOverviewView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var analyticsService: AnalyticsService
    @EnvironmentObject var formatters: FormattersHolder
    @StateObject var vm: BudgetOverviewViewModel
    
    @State var spendings: SpengingsType = .overall
    
    var loadStats: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    HStack(spacing: 30) {
                        CirclularBudgetProgressView(
                            progress: [
                                getTotalSpent(),
                                getFixedSpent(),
                                getPercentSpent()
                            ],
                            colors: [Color.appExpensesAll, Color.appExpensesFixed, Color.appExpensesFlexible],
                            selected: spendings.rawValue,
                            gap: true
                        ) {
                            VStack {
                                Text(formatters.formatPercent(getTotalSpentDecimal()))
                                    .font(.title3)
                                    .bold()
                                Text("Spent")
                                    .font(.caption)
                            }
                        }
                        .frame(width: getMaxSize(geometry.size.width), height: getMaxSize(geometry.size.width))
                        .accessibilityLabel("\(getTotalSpent())% Spent")
                        .accessibilityElement(children: .combine)
                        SpenginsView()
                    }
                    .padding(.top, 30)
                    HStack {
                        SliderView(icon: "chevron.left") {
                            nextTab()
                        }
                        .disabled(spendings == .overall)
                        .padding(.leading, 15)
                        TabView(selection: $spendings) {
                            SpendingsView(
                                title: "Expenses",
                                firstColor: Color.appExpensesAll,
                                secondColor: Color.appExpensesAll.opacity(0.3),
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
                                firstColor: Color.appExpensesFixed,
                                secondColor: Color.appExpensesFixed.opacity(0.3),
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
                                firstColor: Color.appExpensesFlexible,
                                secondColor: Color.appExpensesFlexible.opacity(0.3),
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
                        SliderView(icon: "chevron.right") {
                            previousTab()
                        }
                        .disabled(spendings == .flexible)
                        .padding(.trailing, 15)
                    }
                    FlexibleCardView {
                        VStack {
                            ShortNotificationsListView(notifications: $vm.notifications)
                            NavigationLink(value: CategoryNotificationsRef(category: nil)) {
                                HStack {
                                    Text("Reminders")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.caption)
                                .tint(Color.appLink)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    Color.clear
                        .frame(height: 70)
                }
            }
            .background(Color.appBackground)
            .onAppear {
                vm.subscribe()
                if loadStats {
                    vm.loadAmounts()
                }
                vm.loadNotifications()
                analyticsService.logEvent(name: AnalyticsService.BUDGET_OPEN_MAIN)
            }
            .onDisappear {
                vm.cancelAll()
            }
        }
    }
    
    @ViewBuilder
    func AmountView(_ amount: Decimal, isSpent: (Decimal) -> Bool) -> some View {
        Text(formatters.formatAmount(amount))
            .foregroundColor(isSpent(amount) ? Color.appDestructiveLink : Color.appCardTextColor)
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
                .font(.caption)
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
        VStack {
            HelpButton {
                appState.showHelpPage(for: .mainPage)
            }
            ForEach(SpengingsType.allCases) { type in
                Button {
                    spendings = type
                } label: {
                    FlexibleCardView(cornerRadius: 7, color: spendings == type ? getTypeColor(type) : Color.appBackground) {
                        Image(systemName: getIconForPage(type))
                            .foregroundColor(spendings == type ? Color.appButtonTextColor : Color.appLink)
                            .bold()
                    }
                    .frame(width: 45, height: 45)
                }
            }
        }
    }
    
    func getTypeColor(_ type: SpengingsType) -> Color {
        switch type {
        case .overall:
            Color.appExpensesAll
        case .fixed:
            Color.appExpensesFixed
        case .flexible:
            Color.appExpensesFlexible
        }
    }
    
    func getMaxSize(_ width: CGFloat) -> CGFloat {
        let value = width * 0.6
        return value <= 400 ? value : 400
    }
    
    func nextTab() {
        if let previous = SpengingsType(rawValue: spendings.rawValue - 1) {
            spendings = previous
        }
    }
    
    func previousTab() {
        if let next = SpengingsType(rawValue: spendings.rawValue + 1) {
            spendings = next
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
    let budgetService = bundle.budgetService
    let notificationService = bundle.notificationService
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
            budgetService: bundle.budgetService, dataService: bundle.dataService,
            analyticsService: bundle.analyticsService
        )
        
        let vm = BudgetOverviewViewModel(
            parent: parent, 
            budgetService: bundle.budgetService,
            notificationService: bundle.notificationService,
            analyticsService: bundle.analyticsService
        )
        
        vm.totalPlannedFixedOutcome = 600
        vm.totalPlannedPercentOutcomeAmount = 1500
        vm.totalOutcome = 2000
        vm.totalBudgetLeft = 1500
        vm.totalFixedOutcome = 450
        vm.totalPercentOutcome = 1000
        vm.totalFixedBudgetLeft = 1000
        vm.totalFlexibleBudgetLeft = 500
        
        let category = budgetService.newCategoryEntity(budget)
        category.typeValue = .outcomeFixed
        category.name = "Rreview"
        category.iconName = "fi-loan"
        
        let notification1 = budgetService.newNotificationEntity(budget)
        notification1.name = "Preview 1"
        notification1.typeValue = .exact
        notification1.date = Date().plusHour(-1)
        notification1.enabled = true
        notification1.category = category
        
        let notification2 = budgetService.newNotificationEntity(budget)
        notification2.name = "Preview 2"
        notification2.typeValue = .daily
        notification2.date = Date()
        notification2.enabled = true
        
        let notification3 = budgetService.newNotificationEntity(budget)
        notification3.name = "Preview 3"
        notification3.typeValue = .weekly
        notification3.date = Date()
        notification3.weekDaysArr = [1, 2, 3, 4, 5, 6, 7]
        notification3.enabled = true
        
        return BudgetOverviewView(vm: vm, loadStats: false)
            .serviceBundle(bundle)
            .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
            .environmentObject(AppState(bundle: bundle))
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
            budgetService: bundle.budgetService, dataService: bundle.dataService,
            analyticsService: bundle.analyticsService
        )
        
        let vm = BudgetOverviewViewModel(
            parent: parent, 
            budgetService: bundle.budgetService,
            notificationService: bundle.notificationService,
            analyticsService: bundle.analyticsService
        )
        
        vm.totalPlannedFixedOutcome = 600
        vm.totalPlannedPercentOutcomeAmount = 1500
        vm.totalOutcome = 2000
        vm.totalBudgetLeft = 1500
        vm.totalFixedOutcome = 450
        vm.totalPercentOutcome = 1550
        vm.totalFixedBudgetLeft = 1000
        vm.totalFlexibleBudgetLeft = 500
        
        return BudgetOverviewView(vm: vm, loadStats: false)
            .serviceBundle(bundle)
            .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
            .environmentObject(AppState(bundle: bundle))
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
            budgetService: bundle.budgetService, dataService: bundle.dataService,
            analyticsService: bundle.analyticsService
        )
        
        let vm = BudgetOverviewViewModel(
            parent: parent,
            budgetService: bundle.budgetService,
            notificationService: bundle.notificationService,
            analyticsService: bundle.analyticsService
        )
        
        vm.totalPlannedFixedOutcome = 600
        vm.totalPlannedPercentOutcomeAmount = 1500
        vm.totalOutcome = 4000
        vm.totalBudgetLeft = -500
        vm.totalFixedOutcome = 650
        vm.totalPercentOutcome = 1550
        vm.totalFixedBudgetLeft = 1000
        vm.totalFlexibleBudgetLeft = 500
        
        return BudgetOverviewView(vm: vm, loadStats: false)
            .serviceBundle(bundle)
            .environmentObject(FormattersHolder(locale: Locale(identifier: "en_US")))
            .environmentObject(AppState(bundle: bundle))
    } catch {
        return Text("Something went wrong \(error)")
    }
}
