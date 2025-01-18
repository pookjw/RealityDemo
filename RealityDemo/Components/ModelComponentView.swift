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
                    
                    // ExtrudingText을 쓴다면
//                    component.materials = []
                }
            }
            
            Section("Materials") {
                ForEach(component.materials.map({ AnyMaterial(material: $0) })) { material in
                    Text(material.unwrappedValue.__resource.name)
                }
            }
            
            HStack {
                Text("boundsMargin")
                Slider(value: $component.boundsMargin, in: -1.0...1.0)
            }
        }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Remove Component", systemImage: "trash") {
                        entity.components.remove(ModelComponent.self)
                        realityService.popToEntitySettings()
                    }
                    .labelStyle(.iconOnly)
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
