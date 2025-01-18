//
//  FontPicker.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/18/25.
//

import SwiftUI

struct FontPicker: UIViewControllerRepresentable {
    private let configuration: UIFontPickerViewController.Configuration
    private let didCancelHandler: () -> Void
    private let didPickFontHandler: (UIFontDescriptor?) -> Void
    
    init(
        configuration: UIFontPickerViewController.Configuration,
        didCancelHandler: @escaping () -> Void,
        didPickFontHandler: @escaping (UIFontDescriptor?) -> Void
    ) {
        self.configuration = configuration
        self.didCancelHandler = didCancelHandler
        self.didPickFontHandler = didPickFontHandler
    }
    
    func makeUIViewController(context: Context) -> UIFontPickerViewController {
        let viewController = UIFontPickerViewController(configuration: configuration)
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIFontPickerViewController, context: Context) {
        context.coordinator.didCancelHandler = didCancelHandler
        context.coordinator.didPickFontHandler = didPickFontHandler
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(didCancelHandler: didCancelHandler, didPickFontHandler: didPickFontHandler)
    }
}

extension FontPicker {
    @MainActor final class Coordinator: NSObject, UIFontPickerViewControllerDelegate {
        fileprivate var didCancelHandler: () -> Void
        fileprivate var didPickFontHandler: (UIFontDescriptor?) -> Void
        
        fileprivate init(
            didCancelHandler: @escaping () -> Void,
            didPickFontHandler: @escaping (UIFontDescriptor?) -> Void
        ) {
            self.didCancelHandler = didCancelHandler
            self.didPickFontHandler = didPickFontHandler
            super.init()
        }
        
        func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
            didCancelHandler()
        }
        
        func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
            didPickFontHandler(viewController.selectedFontDescriptor)
        }
    }
}
