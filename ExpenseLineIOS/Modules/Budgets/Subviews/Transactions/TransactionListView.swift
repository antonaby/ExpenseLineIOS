//
//  TransactionListView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 17.04.24.
//

import SwiftUI

struct TransactionCard: View {
    
    var vm: BudgetViewModel
    let transaction: TransactionEntity
    
    @Binding var selectedTransaction: TransactionEntity?
    
    let onDelete: (TransactionEntity) -> Void
    
    init(vm: BudgetViewModel,
         transaction: TransactionEntity,
         selectedTransaction: Binding<TransactionEntity?>,
         onDelete: @escaping (TransactionEntity) -> Void) {
        self.vm = vm
        self.transaction = transaction
        self._selectedTransaction = selectedTransaction
        self.onDelete = onDelete
    }
    
    var body: some View {
        FlexibleCardView {
            NavigationLink(value: transaction) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        IconView(
                            name: transaction.category?.iconNameValue ?? "question",
                            color: transaction.category?.colorValue ?? .black,
                            size: 45
                        )
                        VStack(alignment: .listRowSeparatorLeading) {
                            Text(transaction.category?.name ?? "?")
                                .font(.caption)
                            Text(transaction.name ?? "?")
                                .bold()
                        }
                    }
                    Text(vm.formatAmount(transaction.amountDecimal))
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(vm.formatDate(transaction.createdAt))
                        .font(.caption)
                }
                .tint(.black)
            }
            .overlay(alignment: .topTrailing) {
                Menu {
                    Button {
                        selectedTransaction = transaction
                    } label: {
                        Text("Edit")
                    }
                    Button(role: .destructive) {
                        onDelete(transaction)
                    } label: {
                        Text("Delete")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .tint(Color("FrDefault"))
                        .frame(width: 50, height: 50, alignment: .topTrailing)
                        .padding([.top, .trailing], 10)
                }
            }
        }
    }
}

struct TransactionListView: View {
    
    @EnvironmentObject var budgetService: BudgetService
    
    @StateObject var vm: TransactionListViewModel
    @State var selectedTransaction: TransactionEntity?
    @State var showPeriod: Bool = false
    @State var chevronRotate: Double = 0
    
    var body: some View {
        VStack {
            ContentSizeCardView {
                VStack(spacing: 10) {
                    HStack {
                        TextField("Search", text: $vm.serachFilter)
                            .overlay(alignment: .trailing) {
                                if !vm.serachFilter.isEmpty {
                                    Button {
                                        vm.clearSearchFilter()
                                    } label: {
                                        Text("Clear")
                                            .font(.caption)
                                            .foregroundStyle(Color("FrDefault"))
                                    }
                                }
                            }
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showPeriod.toggle()
                                chevronRotate += 180
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .foregroundStyle(Color("FrDefault"))
                                .rotationEffect(Angle(degrees: chevronRotate))
                        }
                    }
                    if showPeriod {
                        Divider()
                        DatePicker("From", selection: $vm.startsAt)
                            .datePickerStyle(.compact)
                            .environment(\.locale, Locale.current)
                        DatePicker("To", selection: $vm.endsAt)
                            .datePickerStyle(.compact)
                            .environment(\.locale, Locale.current)
                    }
                }
            }
            .padding(.bottom, 5)
            ScrollView {
                LazyVStack {
                    ForEach(vm.transactions) { transaction in
                        TransactionCard(
                            vm: vm.parent,
                            transaction: transaction,
                            selectedTransaction: $selectedTransaction
                        ) { transaction in
                            vm.deleteTransaction(transaction)
                            vm.loadTransactions()
                        }
                    }
                    Color.clear
                        .frame(height: 70)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 15)
        .background(Color("BgDefault"))
        .sheet(item: $selectedTransaction, onDismiss: loadTransactions) { transaction in
            TransactionSheetView(
                vm: TransactionSheetViewModel(transaction: transaction,
                                              budget: vm.parent.budget,
                                              currency: vm.parent.currency,
                                              budgetService: budgetService))
                .presentationDetents([.medium])
        }
        .onAppear {
            vm.subscribe()
        }
        .onDisappear {
            vm.cancelAll()
        }
    }
    
    func loadTransactions() {
        vm.loadTransactions()
    }
    
}

#Preview {
    let bundle = ServiceBundle.preview
    
    let dm = bundle.databaseManager
    let budgetService = bundle.budgetService
    
    let budget = BudgetEntity(context: dm.viewContext)
    budget.id = UUID()
    budget.name = "Preview"
   
    do {
        let category1 = PlanCategoryEntity(context: dm.viewContext)
        category1.id = UUID()
        category1.name = "Preview 1"
        category1.amount = 0
        category1.percent = 0.2
        category1.iconName = "fl-groceries"
        category1.typeValue = .outcomePercent
        category1.colorValue = .orange
        category1.createdAt = Date()
        category1.budget = budget
        
        let category2 = PlanCategoryEntity(context: dm.viewContext)
        category2.id = UUID()
        category2.name = "Preview 2"
        category2.amount = 2000
        category2.percent = 0
        category2.iconName = "fi-rent"
        category2.typeValue = .outcomeFixed
        category2.colorValue = .green
        category2.createdAt = Date()
        category2.budget = budget
        
        let transaction1 = budgetService.newTransactionEntity(budget)
        transaction1.name = "Test 1"
        transaction1.amountDecimal = 12
        transaction1.createdAt = Date()
        transaction1.category = category1
        
        let transaction2 = budgetService.newTransactionEntity(budget)
        transaction2.name = "Test 2"
        transaction2.amountDecimal = 40
        transaction2.createdAt = Date()
        transaction2.category = category1
        
        let transaction3 = budgetService.newTransactionEntity(budget)
        transaction3.name = "Test 3"
        transaction3.amountDecimal = 300
        transaction3.createdAt = Date()
        transaction3.category = category2
        
        let transaction4 = budgetService.newTransactionEntity(budget)
        transaction4.name = "Test 4"
        transaction4.amountDecimal = 800
        transaction4.createdAt = Date()
        transaction4.category = category2
        
        let vm = BudgetViewModel(
            budget: budget,
            period: try bundle.budgetService.getOrCreateLastPeriod(budget),
            budgetService: bundle.budgetService,
            dataService: bundle.dataService
        )
        
        return TransactionListView(
            vm: TransactionListViewModel(parent: vm, budgetService: budgetService)
        )
            .serviceBundle(bundle)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
