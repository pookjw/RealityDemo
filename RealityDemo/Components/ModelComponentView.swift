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
                    NavigationLink(String(String(describing: type(of: material.unwrappedValue)))) {
                        if let simpleMaterial = material.unwrappedValue as? SimpleMaterial {
                            SimpleMaterialView(
                                simpleMaterial: simpleMaterial,
                                didChangeHandler: { result in
                                    update(material: result)
                                }
                            )
                        } else {
                            Text("Unknown Material Type")
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
    
    private func update(material: any RealityFoundation.Material) {
        var materials: [any RealityFoundation.Material] = component.materials
        
        guard let firstIndex = materials
            .firstIndex(
                where: { Unmanaged.passUnretained($0.__resource).toOpaque() == Unmanaged.passUnretained(material.__resource).toOpaque() })
        else {
            print("No Material found")
            return
        }
        
        materials.remove(at: firstIndex)
        materials.insert(material, at: firstIndex)
        
        component.materials = materials
    }
    
    private func remove(material: any RealityFoundation.Material) {
        var materials: [any RealityFoundation.Material] = component.materials
        
        guard let firstIndex = materials
            .firstIndex(
                where: { Unmanaged.passUnretained($0.__resource).toOpaque() == Unmanaged.passUnretained(material.__resource).toOpaque() })
        else {
            print("No Material found")
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
