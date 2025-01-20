//
//  UIKitColorPickerBindingMap.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/20/25.
//

import SwiftUI

#warning("REMOVE")

extension EnvironmentValues {
    @Entry private(set) var colorPickerBindingMap = UIKitColorPickerBindingMap.shared
}

@MainActor
final class UIKitColorPickerBindingMap {
    fileprivate static nonisolated let shared = UIKitColorPickerBindingMap()
    
    var bindings: [UUID: Binding<UIColor>] = [:]
    
    fileprivate nonisolated init() {}
}
