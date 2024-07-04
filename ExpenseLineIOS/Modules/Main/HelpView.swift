//
//  HelpView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 23.06.24.
//

import SwiftUI

struct HelpView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var page: HelpPage
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "questionmark")
                    .foregroundStyle(Color.appButtonTextColor)
                    .padding(5)
                    .font(.caption)
                    .background(Circle().foregroundStyle(Color.appLink))
                Text("Help")
            }
            .frame(maxWidth: .infinity)
            ScrollView {
                switch page {
                case .mainWizard:
                    MainWizardPage()
                case .incomeWizard:
                    ImcomeWizardPage()
                case .fixedOutcomeWizard:
                    OutcomeFixedWizardPage()
                case .flexibleOutcomeWizard:
                    OutcomeFlexibleWizardPage()
                case .mainPage:
                    MainPage()
                case .notificationPage:
                    NotificationsPage()
                case .transactionPage:
                    TransactionsPage()
                }
            }
            Button {
                dismiss()
            } label: {
                Text("Understood")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .foregroundStyle(Color.appButtonTextColor)
                    .background(RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Color.appLink))
            }
            .padding(.horizontal, 25)
        }
        .padding(.top, 15)
        .padding(.horizontal, 15)
        .background(Color.appBackground)
    }
    
    @ViewBuilder
    func MainWizardPage() -> some View {
        VStack {
            IconView(name: "piggy-bank", color: Color.appLink, size: 60)
            Text("Budget")
                .font(.title2)
                .bold()
            Text("A personal budget is an empowering step towards financial stability and achieving your dreams. It helps you manage income and expenses, prioritize spending, and save for future goals, all while reducing financial stress.")
                .multilineTextAlignment(.center)
                .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func ImcomeWizardPage() -> some View {
        VStack {
            IconView(name: "in-briefcase", color: Color.appLink, size: 60)
            Text("Income")
                .font(.title2)
                .bold()
            Text("Your income is the foundation of your financial life, providing the means to cover essential expenses and save for future goals. Managing and maximizing your income wisely can lead to increased financial stability and a higher quality of life.")
                .multilineTextAlignment(.center)
                .padding(.top, 5)
            HStack {
                Image(systemName: "exclamationmark.square")
                    .foregroundStyle(Color.appLink)
                    .font(.largeTitle)
                Text("Please add at least one income source.")
            }
            .padding([.top], 5)
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func OutcomeFixedWizardPage() -> some View {
        VStack {
            IconView(name: "fi-house", color: Color.appLink, size: 60)
            Text("Fixed Expenses")
                .font(.title2)
                .bold()
            Text("Fixed expenses, such as rent, utilities, and subscriptions, are consistent costs you can anticipate each month. Properly accounting for these necessary outflows ensures you maintain financial stability and can plan effectively for savings and discretionary spending.")
                .multilineTextAlignment(.center)
                .padding(.top, 5)
            HStack {
                Image(systemName: "info.square")
                    .foregroundStyle(Color.appLink)
                    .font(.title2)
                Text("Swipe left to delete a category.")
            }
            .padding([.top], 5)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func OutcomeFlexibleWizardPage() -> some View {
        VStack {
            IconView(name: "fl-shopping", color: Color.appLink, size: 60)
            Text("Flexible Expenses")
                .font(.title2)
                .bold()
            Text("Flexible expenses, such as shopping, coffee, and food delivery, can vary greatly from month to month and are often allocated as a percentage of your budget. By keeping these variable costs in check, you can better manage your overall finances and allocate more funds towards savings and essential expenses.")
                .multilineTextAlignment(.center)
                .padding(.top, 5)
            HStack {
                Image(systemName: "info.square")
                    .foregroundStyle(Color.appLink)
                    .font(.title2)
                Text("Swipe left to delete a category.")
            }
            .padding([.top], 5)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func MainPage() -> some View {
        VStack {
            IconView(name: "piggy-bank", color: Color.appLink, size: 60)
            Text("Budget")
                .font(.title2)
                .bold()
            Text("A comprehensive budget includes overall, fixed, and flexible expenses, providing a clear financial roadmap. Fixed expenses, like rent and subscriptions, are predictable, while flexible expenses, such as shopping and dining out, vary and are typically allocated as a percentage of your budget. Balancing these elements helps ensure financial stability and effective resource management.")
                .multilineTextAlignment(.center)
                .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func NotificationsPage() -> some View {
        VStack {
            Image(systemName: "bell")
                .font(.system(size: 50))
                .foregroundStyle(Color.appLink)
            Text("Reminders")
                .font(.title2)
                .bold()
            Text("Reminders help you stay organized and ensure important tasks and deadlines are not overlooked. They enable you to manage your schedule more effectively and achieve your goals efficiently.")
                .multilineTextAlignment(.center)
                .padding(.top, 5)
            HStack {
                Image(systemName: "info.square")
                    .foregroundStyle(Color.appLink)
                    .font(.title2)
                Text("Swipe left to edit or delete a notification.")
            }
            .padding([.top], 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Image(systemName: "info.square")
                    .foregroundStyle(Color.appLink)
                    .font(.title2)
                Text("Swipe right to turn a notification on or off.")
            }
            .padding([.top], 5)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func TransactionsPage() -> some View {
        VStack {
            Image(systemName: "wallet.pass")
                .font(.system(size: 50))
                .foregroundStyle(Color.appLink)
            Text("Expenses")
                .font(.title2)
                .bold()
            Text("An expenses list details all your spending, helping you track money flow and spot patterns. It aids in making informed financial decisions.")
                .multilineTextAlignment(.center)
                .padding(.top, 5)
            HStack {
                Image(systemName: "info.square")
                    .foregroundStyle(Color.appLink)
                    .font(.title2)
                Text("Swipe left to edit or delete an entry.")
            }
            .padding([.top], 5)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
    
}

#Preview("Main Wizard") {
    HelpView(page: .mainWizard)
}

#Preview("Income Wizard") {
    HelpView(page: .incomeWizard)
}

#Preview("Outcome Wizard Fixed") {
    HelpView(page: .fixedOutcomeWizard)
}

#Preview("Outcome Wizard Flexible") {
    HelpView(page: .flexibleOutcomeWizard)
}

#Preview("Main") {
    HelpView(page: .mainPage)
}

#Preview("Notifications") {
    HelpView(page: .notificationPage)
}

#Preview("Transactions") {
    HelpView(page: .transactionPage)
}
