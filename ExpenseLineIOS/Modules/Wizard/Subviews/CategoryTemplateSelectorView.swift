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
    var type: CategoryType
    
    @State var mainTemplates: [CategoryTemplateType] = []
    @State var otherTemplates: [CategoryTemplate] = []
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                TemplatesSectionsView(mainTemplates)
                TemplateSection(name: "Other", templates: otherTemplates)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .onAppear {
            let ds = resolver.dataService()
            
            mainTemplates = ds.getCategoryTemplates(of: type)
            otherTemplates = Array(ds.getCategoryTemplates(not: type).map { $0.templates }.joined())
        }
    }
    
    @ViewBuilder
    func TemplatesSectionsView(_ templates: [CategoryTemplateType]) -> some View {
        ForEach(templates) { template in
            TemplateSection(name: template.name, templates: template.templates)
        }
    }
    
    @ViewBuilder
    func TemplateSection(
        name sectionName: String,
        templates: [CategoryTemplate]) -> some View {
        Section {
            ForEach(templates) { category in
                Button {
                    if name.isEmpty {
                        name = category.name
                    }
                    iconName = category.iconName
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
        type: .outcomePercent
    )
    .environmentObject(DependencyResolver.preview)
}
