//
//  CategoryTemplateSelectorView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 01.05.24.
//

import SwiftUI

struct CategoryTemplateSelectorView: View {
    
    private let predifinedColors: [Color] = [.red, .blue, .green, .orange, .yellow, .brown]
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataService: DataService
    
    @Binding var selectedTemplate: CategoryTemplate?
    
    var type: CategoryType
    
    @State private var mainTemplates: [CategoryTemplateType] = []
    @State private var otherTemplates: [CategoryTemplate] = []
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                ToolButton(color: Color.appLink) {
                    dismiss()
                }
            }
            .font(.title2)
            .padding([.top, .horizontal], 10)
            .padding(.bottom, 5)
            .background(Color.appBackgroundSecondary)
            VStack(spacing: 15) {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                        TemplatesSectionsView(mainTemplates)
                        TemplateSection(name: "Other", templates: otherTemplates)
                    }
                }
            }
            .padding([.top], 10)
            .padding([.horizontal], 10)
            .background(Color.appBackground)
            .onAppear {
                mainTemplates = dataService.getCategoryTemplates(of: type)
                otherTemplates = Array(dataService.getCategoryTemplates(not: type).map { $0.templates }.joined())
            }
        }
    }
    
    @ViewBuilder
    func TemplatesSectionsView(_ templates: [CategoryTemplateType]) -> some View {
        ForEach(templates) { template in
            TemplateSection(name: "Categories", templates: template.templates)
        }
    }
    
    @ViewBuilder
    func TemplateSection(
        name sectionName: String,
        templates: [CategoryTemplate]) -> some View {
        Section {
            ForEach(templates) { template in
                Button {
                    selectedTemplate = template
                } label: {
                    FlexibleCardView(color: selectedTemplate?.id == template.id
                                     ? Color.appLink
                                     : Color.appBackgroundSecondary) {
                        VStack {
                            IconView(
                                name: template.iconName,
                                withBacground: false,
                                color: selectedTemplate?.id == template.id
                                ? Color.appButtonTextColor
                                : Color.appCardTextColor,
                                size: 40
                            )
                            Text(template.name)
                                .lineLimit(1)
                                .font(.caption2)
                                .foregroundColor(selectedTemplate?.id == template.id ? Color.appButtonTextColor : Color.appCardTextColor)
                        }
                    }
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
        selectedTemplate: .constant(nil),
        type: .outcomePercent
    )
    .environmentObject(ServiceBundle.preview.dataService)
}
