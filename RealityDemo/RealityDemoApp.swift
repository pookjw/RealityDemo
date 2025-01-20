//
//  RealityDemoApp.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import SwiftUI

@main
struct RealityDemoApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @Environment(\.colorPickerBindingMap) private var colorPickerBindingMap
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        
        WindowGroup("ColorPickerWindow", for: CodableColor.self) { color in
            UIKitColorPicker(
                selectedColor: Binding<UIColor>(
                    get: {
                        color.wrappedValue?.uiKit ?? .clear
                    },
                    set: { newValue in
                        color.wrappedValue = CodableColor(newValue)
                    }
                )
            )
        }
        .windowStyle(.plain)
    }
}
