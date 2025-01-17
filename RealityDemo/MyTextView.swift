//
//  MyTextView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/18/25.
//

import SwiftUI

struct MyTextView: UIViewControllerRepresentable {
    var attributedText: AttributedString
    
    init(attributedText: AttributedString) {
        self.attributedText = attributedText
    }
    
    func makeUIViewController(context: Context) -> MyTextViewController {
        MyTextViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyTextViewController, context: Context) {
        
    }
}
