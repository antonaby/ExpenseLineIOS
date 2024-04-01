//
//  MainView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI


struct BudgetView: View {
    
    @StateObject var vm: BudgetViewModel
    
    @State var createSpaceSheetOpen = false
    @State var createExpenseSheetOpen = false
    @Binding var path: NavigationPath
    
    @EnvironmentObject var resolver: DependencyResolver
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 15) {
                            AddSpaceCircle {
                                createSpaceSheetOpen.toggle()
                            }
                            .frame(alignment: .top)
                            ForEach(vm.spaces) { space in
                                NavigationLink(value: space) {
                                    SpaceCircle(name: getSpaceName(space))
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    Text("Total: \(vm.totalAmount)")
                        .font(.title)
                        .padding([.top], 30)
                    Spacer()
                }
                AddExpenseButton {
                    createExpenseSheetOpen.toggle()
                }
            }
            .sheet(isPresented: $createSpaceSheetOpen, onDismiss: onSpaceCreated) {
                CreateSpaceSheetView(vm: resolver.createSpaceSheetViewModel())
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $createExpenseSheetOpen, onDismiss: onExpenseCreated) {
                CreateExpenseSheetView(vm: resolver.createExpenseSheetViewModel())
                    .presentationDetents([.medium])
            }
            .navigationDestination(for: SpaceEntity.self) { space in
                SpaceView(vm: resolver.spaceViewModel(space))
            }
            .padding([.horizontal], 15)
            .onAppear {
                vm.loadSpaces()
                vm.loadTotalAmount()
            }
        }
    }
    
    func getSpaceName(_ space: SpaceEntity) -> String {
        space.name ?? "Unknown"
    }
    
    func onSpaceCreated() {
        vm.loadSpaces()
    }
    
    func onExpenseCreated() {
        vm.loadTotalAmount()
    }
}

#Preview {
    BudgetView(vm: DependencyResolver.preview.budgetViewModel(), path: .constant(NavigationPath()))
        .environmentObject(DependencyResolver.preview)
}
