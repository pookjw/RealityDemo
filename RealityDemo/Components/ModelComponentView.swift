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
    @State private var materialWrappers: [MaterialWrapper] = []
    
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
                ForEach(materialWrappers) { wrapper in
                    let material = wrapper.material
                    
                    NavigationLink(
                        _mangledTypeName(type(of: material)) ?? _typeName(type(of: material), qualified: true)
                    ) {
                        if let simpleMaterial = material as? SimpleMaterial {
                            SimpleMaterialView(
                                material: Binding<SimpleMaterial>(
                                    get: {
                                        simpleMaterial
                                    },
                                    set: { newValue in
                                        update(oldWrapper: wrapper, newMaterial: newValue)
                                    }
                                )
                            )
                        } else if let occlusionMaterial = material as? OcclusionMaterial {
                            OcclusionMaterialView(
                                material: Binding<OcclusionMaterial>(
                                    get: {
                                        occlusionMaterial
                                    },
                                    set: { newValue in
                                        update(oldWrapper: wrapper, newMaterial: newValue)
                                    }
                                )
                            )
                        } else if let skyboxMaterial = material as? __SkyboxMaterial {
                            SkyboxMaterialView(
                                material: Binding<__SkyboxMaterial>(
                                    get: {
                                        skyboxMaterial
                                    },
                                    set: { newValue in
                                        update(oldWrapper: wrapper, newMaterial: newValue)
                                    }
                                )
                            )
                        } else if let unlitMaterial = material as? UnlitMaterial {
                            UnlitMaterialView(
                                material: Binding<UnlitMaterial>(
                                    get: {
                                        unlitMaterial
                                    },
                                    set: { newValue in
                                        update(oldWrapper: wrapper, newMaterial: newValue)
                                    }
                                )
                            )
                        } else if let physicallyBasedMaterial = material as? PhysicallyBasedMaterial {
                            PhysicallyBasedMaterialView(
                                material: Binding<PhysicallyBasedMaterial>(
                                    get: {
                                        physicallyBasedMaterial
                                    },
                                    set: { newValue in
                                        update(oldWrapper: wrapper, newMaterial: newValue)
                                    }
                                )
                            )
                        } else {
                            Text("Unknown Material Type: \(_typeName(type(of: material), qualified: true))")
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Remove", systemImage: "trash", role: .destructive) {
                            remove(wrapper: wrapper)
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
                    AddMaterialView { material in
                        materialWrappers.append(MaterialWrapper(id: UUID(), material: material))
                    }
                } label: {
                    Label("Add Material", systemImage: "light.overhead.left.fill")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", systemImage: "checkmark") {
                    component.materials = materialWrappers.map { $0.material }
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
            
            let materialWrappers: [MaterialWrapper] = .init(unsafeUninitializedCapacity: component.materials.count) { pointer, count in
                for material in component.materials {
                    let wrapper = MaterialWrapper(id: UUID(), material: material)
                    pointer.baseAddress!.advanced(by: count).initialize(to: wrapper)
                    count += 1
                }
            }
            
            self.materialWrappers = materialWrappers
        }
    }
    
    private func update(oldWrapper: MaterialWrapper, newMaterial: any RealityFoundation.Material) {
        var materialWrappers = materialWrappers
        
        guard let firstIndex = materialWrappers.firstIndex(
            where: { $0.id == oldWrapper.id }
        ) else {
            assertionFailure()
            return
        }
        
        materialWrappers.remove(at: firstIndex)
        
        let newWrapper = MaterialWrapper(id: oldWrapper.id, material: newMaterial)
        materialWrappers.insert(newWrapper, at: firstIndex)
        
        self.materialWrappers = materialWrappers
    }
    
    private func remove(wrapper: MaterialWrapper) {
        var materialWrappers = materialWrappers
        
        guard let firstIndex = materialWrappers.firstIndex(
            where: { $0.id == wrapper.id }
        ) else {
            assertionFailure()
            return
        }
        
        materialWrappers.remove(at: firstIndex)
        
        self.materialWrappers = materialWrappers
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

fileprivate struct MaterialWrapper: Identifiable {
    let id: UUID
    let material: any RealityFoundation.Material
}
