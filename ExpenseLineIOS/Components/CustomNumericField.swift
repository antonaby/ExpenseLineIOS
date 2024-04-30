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
    var delimiter: String
    var isSymbolTrailing: Bool
    
    @State private var internalValue: String
    
    init(text: Binding<String>, 
         showKeyboard: FocusState<Bool>.Binding,
         currencySymbol: String,
         delimiter: String,
         isSymbolTrailing: Bool) {
        self._text = text
        self._showKeyboard = showKeyboard
        self.currencySymbol = currencySymbol
        self.delimiter = delimiter
        self.isSymbolTrailing = isSymbolTrailing
        self.internalValue = text.wrappedValue
            .replacingOccurrences(of: currencySymbol, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showKeyboard.toggle()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(1...9, id: \.self) { index in
                    NumericKeyboardButton(String(index)) {
                        internalValue.append("\(index)")
                        refreshText()
                    }
                }
                NumericKeyboardButton(delimiter) {
                    internalValue.append(delimiter)
                    refreshText()
                }
                NumericKeyboardButton("0") {
                    internalValue.append("0")
                    refreshText()
                }
                Button {
                    if !internalValue.isEmpty {
                        internalValue.removeLast()
                    }
                    refreshText()
                } label: {
                    Image(systemName: "delete.backward")
                        .modifier(KeyboardButtonViewModifier(color: .blue))
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
        .background {
            Rectangle()
                .fill(.white)
                .ignoresSafeArea()
        }
    }
    
    func refreshText() {
        if internalValue.isEmpty {
            text = ""
            return
        }
        
        if isSymbolTrailing {
            text = internalValue + " " + currencySymbol
        } else {
            text = currencySymbol + " " + internalValue
        }
    }
    
    @ViewBuilder
    func NumericKeyboardButton(_ value: String, onTap: @escaping () -> ()) -> some View {
        Button(action: onTap) {
            Text(value)
                .modifier(KeyboardButtonViewModifier(color: .black))
        }
    }
    
}
