//
//  HomeViewModel.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 25.03.24.
//

import Foundation


class HomeViewModel: ObservableObject {
    
    @Published var spaces: [Space]
    
    init() {
        self.spaces = []
    }
    
    func loadSpaces() {
        spaces = [
            Space(id: UUID(), name: "Home", iconName: "No"),
            Space(id: UUID(), name: "Garden", iconName: "No"),
            Space(id: UUID(), name: "Fun", iconName: "No"),
            Space(id: UUID(), name: "Car", iconName: "No"),
            Space(id: UUID(), name: "Vacation", iconName: "No"),
            Space(id: UUID(), name: "Other", iconName: "No"),
        ]
    }
    
}
