//
//  TransactionListView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 17.04.24.
//

import SwiftUI
import Combine

class TransactionListViewModel: ObservableObject {
    
    @Published var serachFilter: String = ""
    @Published var transactions: [TransactionEntity] = []
    
    private let budgetService: BudgetService
    private var cancellables = Set<AnyCancellable>()
    
    init(budgetService: BudgetService) {
        self.budgetService = budgetService
        
        $serachFilter
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                
            }
            .store(in: &cancellables)
    }
    
    func loadTransactions(period: PeriodEntity, budget: BudgetEntity) {
        do {
            if serachFilter.isEmpty {
                transactions = try budgetService.getAllTransactions(period, budget: budget)
            } else {
                
            }
        } catch {
            // TODO: show error
            print("Something went wrong \(error)")
        }
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
}

struct TransactionCard: View {
    
    @ObservedObject var vm: BudgetViewModel
    let transaction: TransactionEntity
    
    @Binding var selectedTransaction: TransactionEntity?
    
    var body: some View {
        FlexibleCardView {
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
                    Spacer()
                    Menu {
                        Button {
                            selectedTransaction = transaction
                        } label: {
                            Text("Edit")
                        }
                        Button(role: .destructive) {
                            vm.deleteTransaction(transaction)
                        } label: {
                            Text("Delete")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    
                }
                Text(vm.formatAmount(transaction.amountDecimal))
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(vm.formatDate(transaction.createdAt))
                    .font(.caption)
            }
        }
    }
}

struct TransactionListView: View {
    
    @EnvironmentObject var budgetService: BudgetService
    
    @StateObject var trVm: TransactionListViewModel
    @ObservedObject var vm: BudgetViewModel
    @State var selectedTransaction: TransactionEntity?
    
    var body: some View {
        VStack {
            ContentSizeCardView {
                TextField("Search", text: $trVm.serachFilter)
            }
            .padding(.bottom, 5)
            ScrollView {
                LazyVStack {
                    ForEach(trVm.transactions) { transaction in
                        TransactionCard(vm: vm, transaction: transaction, selectedTransaction: $selectedTransaction)
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 15)
        .background(Color(uiColor: .secondarySystemBackground))
        .sheet(item: $selectedTransaction, onDismiss: loadTransactions) { transaction in
            TransactionSheetView(
                vm: TransactionSheetViewModel(transaction: transaction,
                                              budget: vm.budget,
                                              currency: vm.currency,
                                              budgetService: budgetService))
                .presentationDetents([.medium])
        }
        .onAppear {
            loadTransactions()
        }
    }
    
    func loadTransactions() {
        trVm.loadTransactions(period: vm.period, budget: vm.budget)
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
            trVm: TransactionListViewModel(budgetService: budgetService),
            vm: vm
        )
            .serviceBundle(bundle)
    } catch {
        return Text("Something went wrong \(error)")
    }
}
