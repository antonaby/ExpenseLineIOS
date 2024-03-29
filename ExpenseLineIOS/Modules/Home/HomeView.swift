//
//  MainView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI


struct HomeView: View {
    
    @StateObject var vm: HomeViewModel
    
    @State var createSpaceSheetOpen = false
    @State var createExpenseSheetOpen = false
    
    @EnvironmentObject var resolver: DependencyResolver
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 15) {
                        AddSpaceCircle {
                            createSpaceSheetOpen.toggle()
                        }
                        .frame(alignment: .top)
                        ForEach(vm.spaces) { space in
                            SpaceCircle(space.name) {
                                print("WIP")
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
        .padding([.horizontal], 15)
        .onAppear {
            vm.loadSpaces()
            vm.loadTotalAmount()
        }
    }
    
    func onSpaceCreated() {
        vm.loadSpaces()
    }
    
    func onExpenseCreated() {
        vm.loadTotalAmount()
    }
}

#Preview {
    HomeView(vm: DependencyResolver.preview.homeViewModel())
        .environmentObject(DependencyResolver.preview)
}
