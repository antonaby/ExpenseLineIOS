//
//  SpaceView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 30.03.24.
//

import SwiftUI

struct SpaceView: View {
    
    @StateObject var vm: SpaceViewModel
    
    var body: some View {
        VStack {
            Text(vm.getName())
                .font(.title)
            ScrollView {
                ForEach(vm.expenses) { expense in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(expense.name ?? "Noname")
                            Spacer()
                            Text("-\(expense.amount)")
                                .font(.subheadline)
                                .foregroundStyle(Color.red)
                        }
                        if let createdAt = expense.createdAt {
                            Text("Created: \(createdAt.formatted())")
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.horizontal], 10)
                    .padding([.vertical], 5)
                    .background(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 1))
                }
                .padding([.top], 5)
                .padding([.horizontal], 10)
            }
            Spacer()
        }.onAppear {
            vm.loadExpenses()
        }
    }
}

#Preview {
    let dm = DependencyResolver.preview.databaseManager()
    let space = SpaceEntity(context: dm.viewContext)
    space.id = UUID()
    space.name = "Test"
    
    let expense = ExpenseEntity(context: dm.viewContext)
    expense.id = UUID()
    expense.name = "Test expense"
    expense.amount = 1000
    expense.space = space
    expense.createdAt = Date()
    
    dm.save()
       
    return SpaceView(vm: DependencyResolver.preview.spaceViewModel(space))
}
