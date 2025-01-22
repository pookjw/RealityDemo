//
//  PhysicallyBasedMaterialView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/19/25.
//

import SwiftUI
import RealityFoundation

struct PhysicallyBasedMaterialView: View {
    @Binding private var material: PhysicallyBasedMaterial
    private let completionHandler: (() -> Void)?
    @State private var pop = false
    @State private var key = UUID()
    
    init(
        material: Binding<PhysicallyBasedMaterial>,
        completionHandler: (() -> Void)? = nil
    ) {
        _material = material
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        Form {
            Section {
                NavigationLink {
                    UIKitColorPicker(
                        selectedColor: $material.baseColor.tint,
                        continuously: false
                    )
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Open External Color Picker", systemImage: "arrow.up.forward.app") {
                                openExternalColorPickerWindow()
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("baseColor.tint")
                        Spacer()
                        Circle()
                            .fill(Color(uiColor: material.baseColor.tint))
                            .frame(width: 25.0, height: 25.0)
                    }
                }
            }
            
            Section {
                HStack {
                    Text("roughness.scale")
                    Slider(
                        value: $material.roughness.scale,
                        in: 0.0...1.0
                    )
                }
                
                HStack {
                    Text("metallic.scale")
                    Slider(
                        value: $material.metallic.scale,
                        in: 0.0...1.0
                    )
                }
                
                HStack {
                    Text("clearcoat.scale")
                    Slider(
                        value: $material.clearcoat.scale,
                        in: 0.0...1.0
                    )
                }
            }
            
            Section {
                HStack {
                    Text("specular.scale")
                    Slider(
                        value: $material.specular.scale,
                        in: 0.0...1.0
                    )
                }
                
                NavigationLink {
                    UIKitColorPicker(
                        selectedColor: Binding<UIColor>(
                            get: {
                                material.sheen?.tint ?? .clear
                            },
                            set: { newValue in
                                if var sheen = material.sheen {
                                    sheen.tint = newValue
                                    material.sheen = sheen
                                } else {
                                    material.sheen = PhysicallyBasedMaterial.SheenColor(tint: newValue, texture: nil)
                                }
                            }
                        ),
                        continuously: false
                    )
                } label: {
                    HStack {
                        Text("sheen.tint")
                        Spacer()
                        Circle()
                            .fill(Color(uiColor: material.sheen?.tint ?? .clear))
                            .frame(width: 25.0, height: 25.0)
                    }
                }
                
                if material.sheen != nil {
                    Button("sheen = nil") {
                        material.sheen = nil
                    }
                }
            }
            
            Section {
                HStack {
                    Text("clearcoatRoughness.scale")
                    Slider(
                        value: $material.clearcoatRoughness.scale,
                        in: 0.0...1.0
                    )
                }
            }
        }
            .navigationTitle(_typeName(PhysicallyBasedMaterial.self))
            .toolbar {
                if let completionHandler {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done", systemImage: "checkmark") {
                            completionHandler()
                            pop = true
                        }
                    }
                }
            }
            .pop(pop)
    }
    
    private func openExternalColorPickerWindow() {
        let userActivity = NSUserActivity(activityType: "\(Bundle.main.bundleIdentifier!).openWindowByID")
        
        let key = key
        let encoder = JSONEncoder()
        let data = try! encoder.encode(key)
        userActivity.userInfo = [
            "com.apple.SwiftUI.sceneValue": data,
            "com.apple.SwiftUI.sceneID": "ColorPickerWindow"
        ]
        
        UIKitColorPickerBindingMap.shared.bindings[key] = $material.baseColor.tint
        
        let request = UISceneSessionActivationRequest(
            role: .windowApplication,
            userActivity: userActivity,
            options: nil
        )
        
        UIApplication.shared.activateSceneSession(for: request) { error in
            fatalError("\(error)")
        }
    }
}
