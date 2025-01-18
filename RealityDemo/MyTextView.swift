//
//  MyTextView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/18/25.
//

import SwiftUI

struct MyTextView: UIViewControllerRepresentable {
    private let attributedText: Binding<AttributedString>
    
    init(attributedText: Binding<AttributedString>) {
        self.attributedText = attributedText
    }
    
    func makeUIViewController(context: Context) -> MyTextViewController {
        let viewController = MyTextViewController()
        viewController.textView.delegate = context.coordinator
        viewController.textView.attributedText = NSAttributedString(attributedText.wrappedValue)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: MyTextViewController, context: Context) {
        context.coordinator.attributedText = attributedText
        uiViewController.textView.attributedText = NSAttributedString(attributedText.wrappedValue)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(attributedText: attributedText)
    }
}

extension MyTextView {
    @MainActor final class Coordinator: NSObject, UITextViewDelegate {
        fileprivate var attributedText: Binding<AttributedString>
        
        fileprivate init(attributedText: Binding<AttributedString>) {
            self.attributedText = attributedText
        }
        
        func textViewDidChange(_ textView: UITextView) {
            attributedText.wrappedValue = AttributedString(textView.attributedText)
        }
    }
}
