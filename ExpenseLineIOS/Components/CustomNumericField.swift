//
//  CustomNumericKeybord.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 27.04.24.
//

import SwiftUI

struct CustomNumericField<Content: View>: UIViewRepresentable {
    
    var text: String
    
    private var font: UIFont
    private var alignment: NSTextAlignment
    private var placeholder: String
    private var placeholderColor: UIColor
    private var keyboardContent: Content
    
    @State private var keyboardController: UIHostingController<Content>?
    
    init(text: String,
         placeholder: String,
         placeholderColor: UIColor = UIColor.gray,
         font: UIFont = UIFont.systemFont(ofSize: 30),
         alignment: NSTextAlignment = NSTextAlignment.center,
         @ViewBuilder keyboard: @escaping () -> Content) {
        self.text = text
        self.placeholder = placeholder
        self.placeholderColor = placeholderColor
        self.font = font
        self.alignment = alignment
        self.keyboardContent = keyboard()
    }
       
    func makeUIView(context: Context) -> UITextField {
        let textfield = UITextField()
        let placeholder =  NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: placeholderColor
            ])
        textfield.attributedPlaceholder = placeholder
        textfield.delegate = context.coordinator
        textfield.inputView = UIView()
        textfield.inputAccessoryView = UIView()
        textfield.font = font
        textfield.textAlignment = alignment
        textfield.tintColor = .clear
        return textfield
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        DispatchQueue.main.async {
            if keyboardController == nil {
                keyboardController = UIHostingController(rootView: keyboardContent)
                keyboardController?.view.frame = .init(origin: .zero, size: keyboardController?.view.intrinsicContentSize ?? .zero)
                uiView.inputView = keyboardController?.view
                uiView.reloadInputViews()
            } else {
                keyboardController?.rootView = keyboardContent
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
      
    }
    
}

struct KeyboardButtonViewModifier: ViewModifier {
    
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
    }
    
}

struct CustomNumericKeybord: View {
    
    @Binding var text: String
    @FocusState.Binding var showKeyboard: Bool
    var currencySymbol: String
    var separator: String
    var isSymbolTrailing: Bool
    
    @State private var internalValue: String
    @State private var isEnabled: Bool = true
    
    init(text: Binding<String>, 
         showKeyboard: FocusState<Bool>.Binding,
         currencySymbol: String,
         separator: String,
         isSymbolTrailing: Bool) {
        self._text = text
        self._showKeyboard = showKeyboard
        self.currencySymbol = currencySymbol
        self.separator = separator
        self.isSymbolTrailing = isSymbolTrailing
        self.internalValue = text.wrappedValue
            .replacingOccurrences(of: currencySymbol, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        VStack {
            Grid {
                GridRow {
                    ForEach(1...3, id: \.self) { index in
                        NumericKeyboardButton(String(index)) {
                            internalValue.append("\(index)")
                            refreshText()
                        }
                    }
                    Button {
                        if !internalValue.isEmpty {
                            internalValue.removeLast()
                        }
                        refreshText()
                    } label: {
                        Image(systemName: "delete.backward")
                            .modifier(KeyboardButtonViewModifier(color: Color.appDestructiveLink))
                    }
                }
                GridRow {
                    ForEach(4...6, id: \.self) { index in
                        NumericKeyboardButton(String(index)) {
                            internalValue.append("\(index)")
                            refreshText()
                        }
                    }
                    Button {
                        showKeyboard.toggle()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.appLink)
                    }
                }
                GridRow {
                    ForEach(7...9, id: \.self) { index in
                        NumericKeyboardButton(String(index)) {
                            internalValue.append("\(index)")
                            refreshText()
                        }
                    }
                }
                GridRow {
                    NumericKeyboardButton(separator) {
                        internalValue.append(separator)
                        refreshText()
                    }
                    NumericKeyboardButton("0") {
                        internalValue.append("0")
                        refreshText()
                    }
                    
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
        .background {
            Rectangle()
                .fill(Color.appBackgroundSecondary)
                .ignoresSafeArea()
        }
        .onAppear {
            checkEnabled()
        }
    }
    
    func refreshText() {
        if internalValue.isEmpty {
            text = ""
            isEnabled = true
            return
        }
        
        if isSymbolTrailing {
            text = internalValue + " " + currencySymbol
        } else {
            text = currencySymbol + " " + internalValue
        }
        
        checkEnabled()
    }
    
    func checkEnabled() {
        let components = internalValue.split(separator: separator)
        if components.count == 2 {
            isEnabled = components[1].count < 2
        }
    }
    
    @ViewBuilder
    func NumericKeyboardButton(_ value: String, onTap: @escaping () -> ()) -> some View {
        Button(action: onTap) {
            Text(value)
                .modifier(KeyboardButtonViewModifier(color: isEnabled ? Color.appCardTextColor : Color.appLinkInactive))
        }
        .disabled(!isEnabled)
    }
    
}
