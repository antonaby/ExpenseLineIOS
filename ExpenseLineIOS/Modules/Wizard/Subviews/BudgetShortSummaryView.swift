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
    do {
        let vm = try DependencyResolver.preview.budgetWizzardViewModel()
        return BudgetShortSummaryView(vm: vm)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
