//
//  SimpleMaterialView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/18/25.
//

import SwiftUI
import RealityFoundation

struct SimpleMaterialView: View {
    @State private var simpleMaterial: SimpleMaterial
    private let didChangeHandler: ((SimpleMaterial) -> Void)?
    private let completionHandler: ((SimpleMaterial) -> Void)?
    @State private var pop = false
    
    init(
        simpleMaterial: SimpleMaterial = SimpleMaterial(
            color: SimpleMaterial.Color(white: .zero, alpha: 1.0),
            isMetallic: true
        ),
        didChangeHandler: ((SimpleMaterial) -> Void)? = nil,
        completionHandler: ((SimpleMaterial) -> Void)? = nil
    ) {
        _simpleMaterial = State<SimpleMaterial>(initialValue: simpleMaterial)
        self.didChangeHandler = didChangeHandler
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        Form {
            NavigationLink {
                UIKitColorPicker(
                    selectedColor: $simpleMaterial.color.tint,
                    continuously: false
                )
            } label: {
                HStack {
                    Text("Tint Color")
                    Spacer()
                    Circle()
                        .fill(Color(uiColor: simpleMaterial.color.tint))
                        .frame(width: 25.0, height: 25.0)
                }
            }
            
            HStack {
                Text("Metallic")
                Slider(value: $simpleMaterial[\.metallic], in: 0.0...1.0)
            }
            
            HStack {
                Text("Roughness")
                Slider(value: $simpleMaterial[\.roughness], in: 0.0...1.0)
            }
            
            Section("Face Culling") {
                ForEach(SimpleMaterial.FaceCulling.allCases) { faceCulling in
                    Button {
                        simpleMaterial.faceCulling = faceCulling
                    } label: {
                        Label {
                            Text(faceCulling.title)
                        } icon: {
                            if simpleMaterial.faceCulling == faceCulling {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            Section("Triangle Fill Mode") {
                ForEach(SimpleMaterial.TriangleFillMode.allCases) { triangleFillMode in
                    Button {
                        simpleMaterial.triangleFillMode = triangleFillMode
                    } label: {
                        Label {
                            Text(triangleFillMode.title)
                        } icon: {
                            if simpleMaterial.triangleFillMode == triangleFillMode {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            Section {
                Toggle("Reads Depth", isOn: $simpleMaterial.readsDepth)
                Toggle("Writes Depth", isOn: $simpleMaterial.writesDepth)
            }
            
            Image("material")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .navigationTitle("SimpleMaterial")
        .toolbar {
            if let completionHandler {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", systemImage: "checkmark") {
                        completionHandler(simpleMaterial)
                        pop = true
                    }
                }
            }
        }
        .pop(pop)
        .onDisappear {
            pop = false
        }
        .onChange(of: simpleMaterial.color.tint, initial: false) { oldValue, newValue in
            didChangeHandler?(simpleMaterial)
        }
        .onChange(of: simpleMaterial.metallic, initial: false) { oldValue, newValue in
            didChangeHandler?(simpleMaterial)
        }
        .onChange(of: simpleMaterial.roughness, initial: false) { oldValue, newValue in
            didChangeHandler?(simpleMaterial)
        }
        .onChange(of: simpleMaterial.faceCulling, initial: false) { oldValue, newValue in
            didChangeHandler?(simpleMaterial)
        }
        .onChange(of: simpleMaterial.triangleFillMode, initial: false) { oldValue, newValue in
            didChangeHandler?(simpleMaterial)
        }
        .onChange(of: simpleMaterial.readsDepth, initial: false) { oldValue, newValue in
            didChangeHandler?(simpleMaterial)
        }
        .onChange(of: simpleMaterial.writesDepth, initial: false) { oldValue, newValue in
            didChangeHandler?(simpleMaterial)
        }
    }
}

extension SimpleMaterial {
    fileprivate subscript(_keyPath: WritableKeyPath<Self, UIColor>) -> UIColor {
        get {
            self[keyPath: _keyPath]
        }
        set {
            self[keyPath: _keyPath] = newValue
        }
    }
    
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
}
