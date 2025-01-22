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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        
        WindowGroup("ColorPickerWindow", for: UUID.self) { key in
            Group {
                if let wrappedValue = key.wrappedValue,
                   let binding = UIKitColorPickerBindingMap.shared.bindings[wrappedValue] {
                    UIKitColorPicker(selectedColor: binding)
                } else {
                    Text("No Binding!")
                        .padding()
                }
            }
            .glassBackgroundEffect()
        }
        .windowStyle(.plain)
    }
}
