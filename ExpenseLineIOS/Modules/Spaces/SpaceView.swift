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
            Spacer()
        }
    }
}

#Preview {
    let dm = DependencyResolver.preview.databaseManager()
    let entity = SpaceEntity(context: dm.viewContext)
    entity.id = UUID()
    entity.name = "Test"
    dm.save()
       
    return SpaceView(vm: DependencyResolver.preview.spaceViewModel(entity))
}
