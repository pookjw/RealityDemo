//
//  SimpleMaterialView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/18/25.
//

import SwiftUI
import RealityFoundation

struct SimpleMaterialView: View {
    @Binding private var material: SimpleMaterial
    private let completionHandler: (() -> Void)?
    @State private var pop = false
    
    init(
        material: Binding<SimpleMaterial>,
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
                        selectedColor: $material.color.tint,
                        continuously: false
                    )
                } label: {
                    HStack {
                        Text("Tint Color")
                        Spacer()
                        Circle()
                            .fill(Color(uiColor: material.color.tint))
                            .frame(width: 25.0, height: 25.0)
                    }
                }
                
                NavigationLink {
                    UIKitColorPicker(
                        selectedColor: $material[\SimpleMaterial.__emissive],
                        continuously: false
                    )
                } label: {
                    HStack {
                        Text("Emissive")
                        Spacer()
                        Circle()
                            .fill(Color(uiColor: material[\SimpleMaterial.__emissive]))
                            .frame(width: 25.0, height: 25.0)
                    }
                }
            }
            
            Section {
                HStack {
                    Text("Metallic")
                    Slider(value: $material[\.metallic], in: 0.0...1.0)
                }
                
                HStack {
                    Text("Roughness")
                    Slider(value: $material[\.roughness], in: 0.0...1.0)
                }
            }
            
            Section("Face Culling") {
                ForEach(SimpleMaterial.FaceCulling.allCases) { faceCulling in
                    Button {
                        material.faceCulling = faceCulling
                    } label: {
                        Label {
                            Text(faceCulling.title)
                        } icon: {
                            if material.faceCulling == faceCulling {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            Section("Triangle Fill Mode") {
                ForEach(SimpleMaterial.TriangleFillMode.allCases) { triangleFillMode in
                    Button {
                        material.triangleFillMode = triangleFillMode
                    } label: {
                        Label {
                            Text(triangleFillMode.title)
                        } icon: {
                            if material.triangleFillMode == triangleFillMode {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            Section {
                Toggle("Reads Depth", isOn: $material.readsDepth)
                Toggle("Writes Depth", isOn: $material.writesDepth)
                Toggle("Uses Transparency", isOn: $material.__usesTransparency)
            }
            
            Section {
                Image("material")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .navigationTitle(_typeName(SimpleMaterial.self))
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
        .onDisappear {
            pop = false
        }
    }
}

extension SimpleMaterial {
    fileprivate subscript(_keyPath: WritableKeyPath<Self, MaterialScalarParameter>) -> Float {
        get {
            let paramter = self[keyPath: _keyPath]
            switch paramter {
            case .float(let value):
                return value
            case .texture(_):
                fatalError()
            @unknown default:
                fatalError()
            }
        }
        set {
            self[keyPath: _keyPath] = .float(newValue)
        }
    }
    
    fileprivate subscript(_keyPath: WritableKeyPath<Self, __MaterialColorParameter>) -> UIColor {
        get {
            let parameter = self[keyPath: _keyPath]
            switch parameter {
            case .color(let cgColor):
                return UIColor(cgColor: cgColor)
            case .texture(_):
                fatalError()
            @unknown default:
                fatalError()
            }
        }
        set {
            self[keyPath: _keyPath] = .color(newValue.cgColor)
        }
    }
}
