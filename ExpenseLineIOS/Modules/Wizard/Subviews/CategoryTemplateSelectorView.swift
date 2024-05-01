//
//  CategoryTemplateSelectorView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.05.24.
//

import SwiftUI

struct CategoryTemplateSelectorView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var resolver: DependencyResolver
    
    @Binding var name: String
    @Binding var iconName: String
    
    @State var categories: [CategoryTemplateType] = []
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(categories) { type in
                    Section {
                        ForEach(type.templates) { template in
                            Button {
                                name = template.name
                                iconName = template.iconName
                                dismiss()
                            } label: {
                                BaseCardView {
                                    VStack {
                                        Image(systemName: template.iconName)
                                        Text(template.name)
                                    }
                                }
                                .foregroundColor(.black)
                            }
                        }
                    } header: {
                        Text(type.name)
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .onAppear {
            categories = resolver.dataService().getCategoryTemplates()
        }
    }
}

#Preview {
    CategoryTemplateSelectorView(
        name: .constant("Preview"),
        iconName: .constant("case")
    )
    .environmentObject(DependencyResolver.preview)
}
