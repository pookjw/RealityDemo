//
//  UIKitColorPicker.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/18/25.
//

import SwiftUI
import ObjectiveC

struct UIKitColorPicker: UIViewControllerRepresentable {
    private enum DidChangeColor {
        case block(UIColor?, (_ color: UIColor, _ continuously: Bool) -> Void)
        case binding(Binding<UIColor>, Bool)
        
        var didSelectColorHandler: (UIColor, Bool) -> Void {
            { color, continuously in
               switch self {
               case .block(_, let block):
                   block(color, continuously)
               case .binding(let binding, let _continuously):
                   if continuously {
                       if _continuously {
                           binding.wrappedValue = color
                       }
                   } else {
                       binding.wrappedValue = color
                   }
               }
           }
        }
        
        var selectedColor: UIColor? {
            switch self {
            case .block(let color, _):
                return color
            case .binding(let binding, _):
                return binding.wrappedValue
            }
        }
    }
    
    private let shouldUseDarkGridInDarkMode: Bool
    private let userInterfaceStyleForGrid: Int
    private let suggestedColors: [UIColor]
    private let allowsNoColor: Bool
    private let supportsEyedropper: Bool
    private let showsGridOnly: Bool
    private let supportsAlpha: Bool
    private let didSelectColor: DidChangeColor
    private let didFinishHandler: () -> Void
    
    init(
        shouldUseDarkGridInDarkMode: Bool = false,
        userInterfaceStyleForGrid: Int = .zero,
        suggestedColors: [UIColor] = [],
        selectedColor: UIColor? = nil,
        allowsNoColor: Bool = false,
        supportsEyedropper: Bool = true,
        showsGridOnly: Bool = false,
        supportsAlpha: Bool = false,
        didSelectColorHandler: @escaping (_ color: UIColor, _ continuously: Bool) -> Void,
        didFinishHandler: @escaping () -> Void = {}
    ) {
        self.shouldUseDarkGridInDarkMode = shouldUseDarkGridInDarkMode
        self.userInterfaceStyleForGrid = userInterfaceStyleForGrid
        self.suggestedColors = suggestedColors
        self.allowsNoColor = allowsNoColor
        self.supportsEyedropper = supportsEyedropper
        self.showsGridOnly = showsGridOnly
        self.supportsAlpha = supportsAlpha
        self.didSelectColor = .block(selectedColor, didSelectColorHandler)
        self.didFinishHandler = didFinishHandler
    }
    
    init(
        shouldUseDarkGridInDarkMode: Bool = false,
        userInterfaceStyleForGrid: Int = .zero,
        suggestedColors: [UIColor] = [],
        selectedColor: Binding<UIColor>,
        allowsNoColor: Bool = false,
        supportsEyedropper: Bool = true,
        showsGridOnly: Bool = false,
        supportsAlpha: Bool = false,
        continuously: Bool = true,
        didFinishHandler: @escaping () -> Void = {}
    ) {
        self.shouldUseDarkGridInDarkMode = shouldUseDarkGridInDarkMode
        self.userInterfaceStyleForGrid = userInterfaceStyleForGrid
        self.suggestedColors = suggestedColors
        self.allowsNoColor = allowsNoColor
        self.supportsEyedropper = supportsEyedropper
        self.showsGridOnly = showsGridOnly
        self.supportsAlpha = supportsAlpha
        self.didSelectColor = .binding(selectedColor, continuously)
        self.didFinishHandler = didFinishHandler
    }
    
    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let uiViewController = UIColorPickerViewController()
        updateUIViewController(uiViewController, context: context)
        return uiViewController
    }
    
    func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) {
        uiViewController.shouldUseDarkGridInDarkMode = shouldUseDarkGridInDarkMode
        uiViewController.userInterfaceStyleForGrid = userInterfaceStyleForGrid
        uiViewController.suggestedColors = suggestedColors
        uiViewController.allowsNoColor = allowsNoColor
        uiViewController.supportsEyedropper = supportsEyedropper
        uiViewController.showsGridOnly = showsGridOnly
        if let selectedColor = didSelectColor.selectedColor {
            uiViewController.selectedColor = selectedColor
        }
        uiViewController.supportsAlpha = supportsAlpha
        uiViewController.delegate = context.coordinator
        
        context.coordinator.didSelectColorHandler = didSelectColor.didSelectColorHandler
        context.coordinator.didFinishHandler = didFinishHandler
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(didSelectColorHandler: didSelectColor.didSelectColorHandler, didFinishHandler: didFinishHandler)
    }
}

extension UIKitColorPicker {
    @MainActor final class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        fileprivate var didSelectColorHandler: (_ color: UIColor, _ continuously: Bool) -> Void
        fileprivate var didFinishHandler: () -> Void
        
        fileprivate init(didSelectColorHandler: @escaping (_: UIColor, _: Bool) -> Void, didFinishHandler: @escaping () -> Void) {
            self.didSelectColorHandler = didSelectColorHandler
            self.didFinishHandler = didFinishHandler
            super.init()
        }
        
        func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
            didSelectColorHandler(color, continuously)
        }
        
        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            didFinishHandler()
        }
    }
}

extension UIColorPickerViewController {
    fileprivate var shouldUseDarkGridInDarkMode: Bool {
        get {
            let cmd = Selector(("_shouldUseDarkGridInDarkMode"))
            let method = class_getInstanceMethod(Self.self, cmd)!
            let imp = method_getImplementation(method)
            let casted = unsafeBitCast(imp, to: (@convention(c) (UIColorPickerViewController, Selector) -> ObjCBool).self)
            return casted(self, cmd).boolValue
        }
        set {
            let cmd = Selector(("_setShouldUseDarkGridInDarkMode:"))
            let method = class_getInstanceMethod(Self.self, cmd)!
            let imp = method_getImplementation(method)
            let casted = unsafeBitCast(imp, to: (@convention(c) (UIColorPickerViewController, Selector, ObjCBool) -> Void).self)
            casted(self, cmd, ObjCBool(newValue))
        }
    }
    
    fileprivate var userInterfaceStyleForGrid: Int {
        get {
            let cmd = Selector(("_userInterfaceStyleForGrid"))
            let method = class_getInstanceMethod(Self.self, cmd)!
            let imp = method_getImplementation(method)
            let casted = unsafeBitCast(imp, to: (@convention(c) (UIColorPickerViewController, Selector) -> Int).self)
            return casted(self, cmd)
        }
        set {
            let cmd = Selector(("_setUserInterfaceStyleForGrid:"))
            let method = class_getInstanceMethod(Self.self, cmd)!
            let imp = method_getImplementation(method)
            let casted = unsafeBitCast(imp, to: (@convention(c) (UIColorPickerViewController, Selector, Int) -> Void).self)
            casted(self, cmd, newValue)
        }
    }
    
    fileprivate var suggestedColors: [UIColor] {
        get {
            let cmd = Selector(("_suggestedColors"))
            let method = class_getInstanceMethod(Self.self, cmd)!
            let imp = method_getImplementation(method)
            let casted = unsafeBitCast(imp, to: (@convention(c) (UIColorPickerViewController, Selector) -> NSArray).self)
            return casted(self, cmd) as! [UIColor]
        }
        set {
            let cmd = Selector(("_setSuggestedColors:"))
            let method = class_getInstanceMethod(Self.self, cmd)!
            let imp = method_getImplementation(method)
            let casted = unsafeBitCast(imp, to: (@convention(c) (UIColorPickerViewController, Selector, NSArray) -> Void).self)
            casted(self, cmd, newValue as NSArray)
        }
    }
    
    fileprivate var allowsNoColor: Bool {
        get {
            let cmd = Selector(("_allowsNoColor"))
            let method = class_getInstanceMethod(Self.self, cmd)!
            let imp = method_getImplementation(method)
            let casted = unsafeBitCast(imp, to: (@convention(c) (UIColorPickerViewController, Selector) -> ObjCBool).self)
            return casted(self, cmd).boolValue
        }
        set {
            let cmd = Selector(("_setAllowsNoColor:"))
            let method = class_getInstanceMethod(Self.self, cmd)!
            let imp = method_getImplementation(method)
            let casted = unsafeBitCast(imp, to: (@convention(c) (UIColorPickerViewController, Selector, ObjCBool) -> Void).self)
            casted(self, cmd, ObjCBool(newValue))
        }
    }
    
    fileprivate var supportsEyedropper: Bool {
        get {
            let cmd = Selector(("_supportsEyedropper"))
            let method = class_getInstanceMethod(Self.self, cmd)!
            let imp = method_getImplementation(method)
            let casted = unsafeBitCast(imp, to: (@convention(c) (UIColorPickerViewController, Selector) -> ObjCBool).self)
            return casted(self, cmd).boolValue
        }
        set {
            let cmd = Selector(("_setSupportsEyedropper:"))
            let method = class_getInstanceMethod(Self.self, cmd)!
            let imp = method_getImplementation(method)
            let casted = unsafeBitCast(imp, to: (@convention(c) (UIColorPickerViewController, Selector, ObjCBool) -> Void).self)
            casted(self, cmd, ObjCBool(newValue))
        }
    }
    
    fileprivate var showsGridOnly: Bool {
        get {
            let cmd = Selector(("_showsGridOnly"))
            let method = class_getInstanceMethod(Self.self, cmd)!
            let imp = method_getImplementation(method)
            let casted = unsafeBitCast(imp, to: (@convention(c) (UIColorPickerViewController, Selector) -> ObjCBool).self)
            return casted(self, cmd).boolValue
        }
        set {
            let cmd = Selector(("_setShowsGridOnly:"))
            let method = class_getInstanceMethod(Self.self, cmd)!
            let imp = method_getImplementation(method)
            let casted = unsafeBitCast(imp, to: (@convention(c) (UIColorPickerViewController, Selector, ObjCBool) -> Void).self)
            casted(self, cmd, ObjCBool(newValue))
        }
    }
}
