//
//  NotificationView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 07.07.24.
//

import SwiftUI

struct NotificationView: View {
    
    @StateObject var vm: NotificationViewModel
    
    var body: some View {
        ScrollView {
            FlexibleCardView {
                VStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: vm.isActive() ? "bell" : "bell.slash")
                                .foregroundStyle(Color.appLink)
                            Text(vm.notification.nameValue)
                        }
                        .font(.title)
                        if let category = vm.notification.category {
                            HStack {
                                IconView(name: category.iconNameValue)
                                Text(category.nameValue)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .topTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "pencil")
                            .padding([.top, .trailing], 5)
                    }
                    .tint(Color.appLink)
                }
            }
        }
        .padding(.horizontal, 20)
        .background(Color.appBackground)
    }
    
}

#Preview {
    var bundle = ServiceBundle.preview
    var budget = bundle.budgetService.newBudgetEntity()
    
    var category = bundle.budgetService.newCategoryEntity(budget)
    category.name = "Preview category"
    category.iconName = "fl-cloth"
    
    var notification = bundle.notificationService.newNotificationEntity(budget)
    notification.name = "Preview"
    notification.category = category
    notification.typeValue = .daily
    notification.enabled = true
    
    return NotificationView(vm: NotificationViewModel(
        notification: notification,
        notificationService: bundle.notificationService)
    )
}
