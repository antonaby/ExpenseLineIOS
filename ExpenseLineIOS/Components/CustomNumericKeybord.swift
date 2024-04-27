//
//  CustomNumericKeybord.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 27.04.24.
//

import SwiftUI

enum KeyboardValue {
    
    case text(String)
    case image(String)
    
}

struct CustomNumericKeybord: View {
    
    @FocusState.Binding var showKeyboard: Bool
    @Binding var text: String
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 10), count: 3), spacing: 10) {
            ForEach(1...9, id: \.self) { index in
                KeyboardButtonView(.text("\(index)")) {
                    if text.isEmpty {
                        text.append("$")
                    }
                    text.append("\(index)")
                }
            }
            KeyboardButtonView(.image("delete.backward")) {
                if !text.isEmpty {
                    text.removeLast()
                    if text == "$" {
                        text = ""
                    }
                }
            }
            KeyboardButtonView(.text("0")) {
                if text.isEmpty {
                    text.append("$")
                }
                text.append("0")
            }
            KeyboardButtonView(.image("checkmark.circle.fill")) {
                showKeyboard = false
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
    
    @ViewBuilder
    func KeyboardButtonView(_ value: KeyboardValue, onTap: @escaping () -> ()) -> some View {
        Button(action: onTap) {
            ZStack {
                switch value {
                case .text(let string):
                    Text(string)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                case .image(let image):
                    Image(systemName: image)
                        .font(image == "checkmark.circle.fill" ? .title : .title2)
                        .fontWeight(.semibold)
                        .foregroundColor(image == "checkmark.circle.fill" ? .green : .blue)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .contentShape(Rectangle())
        }
    }
    
}

extension TextField {
    @ViewBuilder
    func inputView<Content: View>(hint: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .background {
                SetTFKeyboard(keyboardContent: content(), hint: hint)
            }
    }
}

fileprivate extension UIView {
    var allSubViews: [UIView] {
        return subviews.flatMap { [$0] + $0.subviews }
    }
    
    func findTextField(_ hint: String) -> UITextField? {
        if let textField = allSubViews.first(where: { view in
             let tf = view as? UITextField
            return tf?.placeholder == hint
        }) as? UITextField {
            return textField
        }
        
        return nil
    }
}

fileprivate struct SetTFKeyboard<Content: View>: UIViewRepresentable {
    var keyboardContent: Content
    var hint: String
    
    @State private var hostingController: UIHostingController<Content>?
    
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let textFieldContainerView = uiView.superview?.superview {
                if let textField = textFieldContainerView.findTextField(hint) {
                    if textField.inputView == nil {
                        hostingController = UIHostingController(rootView: keyboardContent)
                        hostingController?.view.frame = .init(origin: .zero, size: hostingController?.view.intrinsicContentSize ?? .zero)
                        textField.delegate = context.coordinator
                        textField.inputView = hostingController?.view
                        textField.reloadInputViews()
                    } else {
                        hostingController?.rootView = keyboardContent
                    }
                } else {
                    print("Failed to Find TF")
                }
            }
        }
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                textField.reloadInputViews()
            }
        }
        
    }
}
