//
//  CurrencySelectorSheet.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 05.05.24.
//

import SwiftUI
import Combine

class CurrencySelectorSheetViewModel: ObservableObject {
    
    @Published var search: String = ""
    @Published var currencies: [CurrencySymbol] = []
    
    private let dataService: DataService
    private var allCurrencies: [CurrencySymbol] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(dataService: DataService) {
        self.dataService = dataService
    }
    
    func loadCurrencies() {
        allCurrencies = dataService.getCurrencies()
        if search.isEmpty {
            clearSerachFilter()
        } else {
            applySearchFilter(search)
        }
        
        $search
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                if value.isEmpty {
                    self?.clearSerachFilter()
                } else {
                    self?.applySearchFilter(value)
                }
            }
            .store(in: &cancellables)
    }
    
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
    }
    
    private func clearSerachFilter() {
        currencies = allCurrencies
    }
    
    private func applySearchFilter(_ value: String) {
        let searchString = value.lowercased()
        
        currencies = allCurrencies.filter {
            $0.name.lowercased().contains(searchString) ||
            $0.code.lowercased().contains(searchString) ||
            $0.symbol.lowercased().contains(searchString)
        }
    }
    
}

struct CurrencySelectorSheet: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var currency: CurrencySymbol
    @StateObject var vm: CurrencySelectorSheetViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ContentSizeCardView {
                TextField("Search", text: $vm.search)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            if !vm.currencies.isEmpty {
                List(vm.currencies) { currencySymbol in
                    Button {
                        currency = currencySymbol
                        dismiss()
                    } label: {
                        HStack {
                            Text(currencySymbol.name)
                            Text(currencySymbol.symbol)
                                .bold()
                            Spacer()
                            Text(currencySymbol.code)
                        }
                        .foregroundColor(.black)
                    }
                }
            } else {
                Text("no results")
                    .bold()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .onAppear {
            vm.loadCurrencies()
        }
        .onDisappear {
            vm.cancelAll()
        }
    }
}

#Preview {
    let bundle = ServiceBundle.preview
    return CurrencySelectorSheet(currency: .constant(CurrencySymbol(id: "en_US", name: "United States")),
                                 vm: CurrencySelectorSheetViewModel(dataService: bundle.dataService))

}
