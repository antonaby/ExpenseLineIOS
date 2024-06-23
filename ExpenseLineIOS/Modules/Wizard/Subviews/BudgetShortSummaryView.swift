//
//  BudgetShowSummaryView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 09.05.24.
//

import SwiftUI

struct BudgetShortSummaryView: View {
    
    @ObservedObject var vm: BudgetWizardViewModel
    
    var body: some View {
        ContentSizeCardView {
            HStack {
                VStack {
                    Text("Income")
                        .font(.caption)
                        .bold()
                    Text(vm.getTotalIncome())
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                Divider()
                    .frame(maxHeight: 30)
                VStack {
                    Text("Outcome")
                        .font(.caption)
                        .bold()
                    Text(vm.getTotalOutcome())
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    let bundle = ServiceBundle.preview
    let vm = BudgetWizardViewModel(
        bundle.budgetService.newBudgetEntity(),
        editMode: true,
        budgetService: bundle.budgetService,
        dataService: bundle.dataService,
        notificationService: bundle.notificationService
    )
    
    return BudgetShortSummaryView(vm: vm)
}
