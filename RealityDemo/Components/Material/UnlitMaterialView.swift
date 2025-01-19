//
//  UnlitMaterialView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/19/25.
//

import SwiftUI
import RealityFoundation

struct UnlitMaterialView: View {
    @Binding private var material: UnlitMaterial
    private let completionHandler: (() -> Void)?
    @State private var pop = false
    
    init(material: Binding<UnlitMaterial>, completionHandler: (() -> Void)? = nil) {
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
            }
            
            Section("Opacity Threshold") {
                Slider(
                    value: Binding(
                        get: {
                            material.opacityThreshold ?? .zero
                        },
                        set: { newValue in
                            material.opacityThreshold = newValue
                        }
                    ),
                    in: 0.0...1.0
                )
                
                if material.opacityThreshold != nil {
                    Button("Set nil (Activate Blending)") {
                        material.opacityThreshold = nil
                    }
                }
            }
            
            if material.opacityThreshold == nil {
                Section("Blending") {
                    Button {
                        material.blending = .opaque
                    } label: {
                        Label {
                            Text("Opaque")
                        } icon: {
                            if case .opaque = material.blending {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    Button {
                        let opacity = PhysicallyBasedMaterial.Opacity(scale: 1.0, texture: nil)
                        material.blending = .transparent(opacity: opacity)
                    } label: {
                        Label {
                            Text("Transparent")
                        } icon: {
                            if case .transparent(_) = material.blending {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    //
                    
                    switch material.blending {
                    case .opaque:
                        EmptyView()
                    case .transparent(let opacity):
                        Text("Texture (TODO)")
                        
                        HStack {
                            Text("Scale")
                            Slider(
                                value: Binding<Float>(
                                    get: {
                                        opacity.scale
                                    },
                                    set: { newValue in
                                        var opacity = opacity
                                        opacity.scale = newValue
                                        material.blending = .transparent(opacity: opacity)
                                    }
                                ),
                                in: 0.0...1.0
                            )
                        }
                    @unknown default:
                        fatalError()
                    }
                }
            }
            
            Section("Face Culling") {
                ForEach(UnlitMaterial.FaceCulling.allCases) { faceCulling in
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
                ForEach(UnlitMaterial.TriangleFillMode.allCases) { triangleFillMode in
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
            }
            
            Section {
                Toggle(
                    "(Program) Apply Post Process Tone Map",
                    isOn: Binding<Bool>(
                        get: {
                            material.program.descriptor.applyPostProcessToneMap
                        },
                        set: { newValue in
                            var descriptor = material.program.descriptor
                            descriptor.applyPostProcessToneMap = newValue
                            
                            Task {
                                material.program = await UnlitMaterial.Program(descriptor: descriptor)
                            }
                        }
                    )
                )
            }
            
            Section("(Program) Blend Mode") {
                Button {
                    Task {
                        var descriptor = material.program.descriptor
                        descriptor.blendMode = nil
                        
                        Task {
                            material.program = await UnlitMaterial.Program(descriptor: descriptor)
                        }
                    }
                } label: {
                    Label {
                        Text("nil")
                    } icon: {
                        if material.program.descriptor.blendMode == nil {
                            Image(systemName: "checkmark")
                        }
                    }

                }
                
                ForEach(MaterialParameterTypes.BlendMode.allCases) { blendMode in
                    Button {
                        Task {
                            var descriptor = material.program.descriptor
                            descriptor.blendMode = blendMode
                            
                            Task {
                                material.program = await UnlitMaterial.Program(descriptor: descriptor)
                            }
                        }
                    } label: {
                        Label {
                            Text(blendMode.title)
                        } icon: {
                            if material.program.descriptor.blendMode == blendMode {
                                Image(systemName: "checkmark")
                            }
                        }

                    }
                }
                
#warning("textureCoordinateTransform")
            }
        }
        .navigationTitle(_typeName(UnlitMaterial.self))
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
