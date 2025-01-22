//
//  UIKitColorPickerBindingMap.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/20/25.
//

import SwiftUI

extension EnvironmentValues {
    @Entry private(set) var colorPickerBindingMap = UIKitColorPickerBindingMap.shared
}

@MainActor
final class UIKitColorPickerBindingMap {
    static nonisolated let shared = UIKitColorPickerBindingMap()
    
    var bindings: [UUID: Binding<UIColor>] = [:]
    
    private nonisolated init() {}
}

extension UIKitColorPickerBindingMap: Equatable {
    static nonisolated func == (lhs: UIKitColorPickerBindingMap, rhs: UIKitColorPickerBindingMap) -> Bool {
        Unmanaged.passUnretained(lhs).toOpaque() == Unmanaged.passUnretained(rhs).toOpaque()
    }
}
