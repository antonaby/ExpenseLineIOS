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
    @Binding var iconName: String?
    @Binding var type: CategoryType
    
    @State var mainTemplates: [CategoryTemplateType] = []
    @State var otherTemplates: [CategoryTemplateType] = []
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                TemplatesSectionsView(mainTemplates)
                TemplatesSectionsView(otherTemplates)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .onAppear {
            let ds = resolver.dataService()
            
            mainTemplates = ds.getCategoryTemplates(of: type)
            otherTemplates = ds.getCategoryTemplates(not: type)
        }
    }
    
    @ViewBuilder
    func TemplatesSectionsView(_ templates: [CategoryTemplateType]) -> some View {
        ForEach(templates) { template in
            TemplateSection(name: template.name, templates: template.templates, type: template.type)
        }
    }
    
    @ViewBuilder
    func TemplateSection(
        name sectionName: String,
        templates: [CategoryTemplate],
        type categoryType: CategoryType) -> some View {
        Section {
            ForEach(templates) { category in
                Button {
                    name = category.name
                    iconName = category.iconName
                    type = categoryType
                    dismiss()
                } label: {
                    FlexibleCardView {
                        VStack {
                            Image(systemName: category.iconName)
                            Text(category.name)
                                .lineLimit(1)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.black)
                }
            }
        } header: {
            Text(sectionName)
                .bold()
                .font(.title3)
        }
    }
    
}

#Preview {
    CategoryTemplateSelectorView(
        name: .constant("Preview"),
        iconName: .constant("case"),
        type: .constant(.outcomePercent)
    )
    .environmentObject(DependencyResolver.preview)
}
