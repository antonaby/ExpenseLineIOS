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
                Spacer()
            }
            AddExpenseButton {
                print("WIP")
            }
        }
        .sheet(isPresented: $createSpaceSheetOpen, onDismiss: onSpaceCreated) {
            CreateSpaceSheetView()
                .presentationDetents([.medium])
        }
        .padding([.horizontal], 15)
        .onAppear {
            vm.loadSpaces()
        }
    }
    
    func onSpaceCreated() {
        vm.loadSpaces()
    }
}

#Preview {
    HomeView()
}
