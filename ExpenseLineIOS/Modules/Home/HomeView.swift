//
//  MainView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import SwiftUI


struct HomeView: View {
    
    @StateObject var vm: HomeViewModel = HomeViewModel()
    
    @State var createSpaceSheetOpen = false
    @State var createExpenseSheetOpen = false
    
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
            CreateSpaceSheetView()
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $createExpenseSheetOpen, onDismiss: onExpenseCreated) {
            CreateExpenseSheetView()
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
    HomeView()
}
