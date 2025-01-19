//
//  ModelComponentView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/17/25.
//

import SwiftUI
import RealityFoundation

struct ModelComponentView: View {
    @Environment(RealityService.self) private var realityService
    
    @State private var component = ModelComponent.defaultComponent
    
    @State private var currentEntity: Entity?
    private let entity: Entity
    
    init(entity: Entity) {
        self.entity = entity
    }
    
    var body: some View {
        Form {
            NavigationLink("MeshResource") {
                MeshResourcesView { mesh in
                    component.mesh = mesh
                }
            }
            
            Section("Materials") {
                ForEach(component.materials.map({ AnyMaterial(material: $0) })) { material in
                    NavigationLink(
                        _mangledTypeName(type(of: material.unwrappedValue)) ?? _typeName(type(of: material.unwrappedValue), qualified: true)
                    ) {
                        if let simpleMaterial = material.unwrappedValue as? SimpleMaterial {
                            SimpleMaterialView(
                                material: Binding<SimpleMaterial>(
                                    get: {
                                        simpleMaterial
                                    },
                                    set: { newValue in
                                        update(oldMaterial: material.unwrappedValue, newMaterial: newValue)
                                    }
                                )
                            )
                        } else if let occlusionMaterial = material.unwrappedValue as? OcclusionMaterial {
                            OcclusionMaterialView(
                                material: Binding<OcclusionMaterial>(
                                    get: {
                                        occlusionMaterial
                                    },
                                    set: { newValue in
                                        update(oldMaterial: material.unwrappedValue, newMaterial: newValue)
                                    }
                                )
                            )
                        } else if let skyboxMaterial = material.unwrappedValue as? __SkyboxMaterial {
                            SkyboxMaterialView(
                                material: Binding<__SkyboxMaterial>(
                                    get: {
                                        skyboxMaterial
                                    },
                                    set: { newValue in
                                        update(oldMaterial: material.unwrappedValue, newMaterial: newValue)
                                    }
                                )
                            )
                        } else if let unlitMaterial = material.unwrappedValue as? UnlitMaterial {
                            UnlitMaterialView(
                                material: Binding<UnlitMaterial>(
                                    get: {
                                        unlitMaterial
                                    },
                                    set: { newValue in
                                        update(oldMaterial: material.unwrappedValue, newMaterial: newValue)
                                    }
                                )
                            )
                        } else if let physicallyBasedMaterial = material.unwrappedValue as? PhysicallyBasedMaterial {
                            PhysicallyBasedMaterialView(
                                material: Binding<PhysicallyBasedMaterial>(
                                    get: {
                                        physicallyBasedMaterial
                                    },
                                    set: { newValue in
                                        update(oldMaterial: material.unwrappedValue, newMaterial: newValue)
                                    }
                                )
                            )
                        } else {
                            Text("Unknown Material Type: \(_typeName(type(of: material.unwrappedValue), qualified: true))")
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Remove", systemImage: "trash", role: .destructive) {
                            remove(material: material.unwrappedValue)
                        }
                    }
                }
            }
            
            HStack {
                Text("boundsMargin")
                Slider(value: $component.boundsMargin, in: -1.0...1.0)
            }
        }
        .navigationTitle(_typeName(ModelComponent.self))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Remove Component", systemImage: "trash", role: .destructive) {
                    entity.components.remove(ModelComponent.self)
                    realityService.popToEntitySettings()
                }
                .labelStyle(.iconOnly)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    AddMaterialView(component: $component)
                } label: {
                    Label("Add Material", systemImage: "light.overhead.left.fill")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", systemImage: "checkmark") {
                    entity.components.set(component)
                    
                    if var collisionComponent = entity.components[CollisionComponent.self] {
                        let shape = ShapeResource.generateConvex(from: component.mesh)
                        collisionComponent.shapes = [shape]
                        entity.components.set(collisionComponent)
                        print("Updated CollisionComponent!")
                    }
                    
                    realityService.popToEntitySettings()
                }
                .labelStyle(.iconOnly)
            }
        }
        .onChange(of: entity, initial: true) { oldValue, newValue in
            guard currentEntity != newValue else { return }
            currentEntity = newValue
            
            let component: ModelComponent
            if let _component = newValue.components[ModelComponent.self] {
                component = _component
            } else {
                component = .defaultComponent
            }
            
            self.component = component
        }
    }
    
    private func update(
        oldMaterial: any RealityFoundation.Material,
        newMaterial: any RealityFoundation.Material
    ) {
        var materials: [any RealityFoundation.Material] = component.materials
        
        guard let firstIndex = materials
            .firstIndex(
                where: { Unmanaged.passUnretained($0.__resource).toOpaque() == Unmanaged.passUnretained(oldMaterial.__resource).toOpaque() }
            )
        else {
            print("No Material found")
            return
        }
        
        materials.remove(at: firstIndex)
        materials.insert(newMaterial, at: firstIndex)
        
        component.materials = materials
    }
    
    private func remove(material: any RealityFoundation.Material) {
        var materials: [any RealityFoundation.Material] = component.materials
        
        guard let firstIndex = materials
            .firstIndex(
                where: { Unmanaged.passUnretained($0.__resource).toOpaque() == Unmanaged.passUnretained(material.__resource).toOpaque() }
            )
        else {
            assertionFailure("No Material found")
            return
        }
        
        materials.remove(at: firstIndex)
        
        component.materials = materials
    }
}

extension ModelComponent {
    @MainActor fileprivate static var defaultComponent: ModelComponent {
        ModelComponent(
            mesh: MeshResource.generateBox(size: .init(x: 0.1, y: 0.1, z: 0.1)),
            materials: [
                SimpleMaterial(color: .init(white: .zero, alpha: 1.0), isMetallic: true)
            ]
        )
    }
}

fileprivate struct AnyMaterial: Identifiable {
    let unwrappedValue: (any RealityFoundation.Material)
    
    init(material: any RealityFoundation.Material) {
        unwrappedValue = material
    }
    
    var id: Int {
        Int(bitPattern: Unmanaged.passUnretained(unwrappedValue.__resource).toOpaque())
    }
}
