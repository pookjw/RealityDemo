//
//  PhysicallyBasedMaterialView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/19/25.
//

import SwiftUI
import RealityFoundation

struct PhysicallyBasedMaterialView: View {
    @Environment(\.openWindow) private var openWindow
    @Binding private var material: PhysicallyBasedMaterial
    private let completionHandler: (() -> Void)?
    @State private var pop = false
    
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
                    .overlay(alignment: .bottom) {
                        Button("Open External Color Picker") {
#warning("Binding?")
                            openWindow(id: "ColorPickerWindow", value: CodableColor(material.baseColor.tint))
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
}
