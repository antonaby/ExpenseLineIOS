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
    
    @Binding var color: Color
    @Binding var selectedTemplate: CategoryTemplate?
    
    var type: CategoryType
    
    @State private var mainTemplates: [CategoryTemplateType] = []
    @State private var otherTemplates: [CategoryTemplate] = []
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                ToolButton(color: Color("FrDefault")) {
                    dismiss()
                }
            }
            .font(.title2)
            .padding([.top, .horizontal], 10)
            .padding(.bottom, 5)
            .background(Color.white)
            VStack(spacing: 15) {
                FlexibleCardView {
                    HStack {
                        ForEach(predifinedColors, id: \.self) { predifinedColor in
                            ColorBoxView(predifinedColor, selected: predifinedColor.toHex() == color.toHex())
                                .frame(maxWidth: .infinity)
                        }
                        Divider()
                        ColorPicker("Color", selection: $color)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxHeight: 50)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                        TemplatesSectionsView(mainTemplates)
                        TemplateSection(name: "Other", templates: otherTemplates)
                    }
                }
            }
            .padding([.top], 10)
            .padding([.horizontal], 10)
            .background(Color("BgDefault"))
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
                    FlexibleCardView(color: selectedTemplate?.id == template.id ? color : .white) {
                        VStack {
                            IconView(
                                name: template.iconName,
                                color: selectedTemplate?.id == template.id ? .white : .black,
                                size: 40
                            )
                            Text(template.name)
                                .lineLimit(1)
                                .font(.caption2)
                                .foregroundColor(selectedTemplate?.id == template.id ? .white : .black)
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
    
    @ViewBuilder
    func ColorBoxView(_ predifinedColor: Color, selected: Bool) -> some View {
        Button {
            color = predifinedColor
        } label: {
            ZStack(alignment: .center) {
                if selected {
                    Circle()
                        .strokeBorder(predifinedColor, lineWidth: 2)
                }
                Circle()
                    .foregroundColor(predifinedColor)
                    .frame(width: 25, height: 25)
            }
            .frame(width: 35, height: 35)
        }
    }
    
}

#Preview {
    CategoryTemplateSelectorView(
        color: .constant(.red),
        selectedTemplate: .constant(nil),
        type: .outcomePercent
    )
    .environmentObject(ServiceBundle.preview.dataService)
}
