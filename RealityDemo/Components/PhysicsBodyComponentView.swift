//
//  PhysicsBodyComponentView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import SwiftUI
import RealityFoundation

struct PhysicsBodyComponentView: View {
    @Environment(RealityService.self) private var realityService
    @State private var component = PhysicsBodyComponent()
    private let entity: Entity
    
    init(entity: Entity) {
        self.entity = entity
    }
    
    var body: some View {
        Form {
            Toggle("isContinuousCollisionDetectionEnabled", isOn: $component.isContinuousCollisionDetectionEnabled)
            
            Section("isRotationLocked") {
                Toggle("X", isOn: $component.isRotationLocked.x)
                Toggle("Y", isOn: $component.isRotationLocked.y)
                Toggle("Z", isOn: $component.isRotationLocked.z)
            }
            
            Toggle("isAffectedByGravity", isOn: $component.isAffectedByGravity)
            
            Section("PhysicsBodyMode") {
                Button {
                    component.mode = .static
                } label: {
                    Label {
                        Text("Static")
                    } icon: {
                        if component.mode == .static {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button {
                    component.mode = .kinematic
                } label: {
                    Label {
                        Text("Kinematic")
                    } icon: {
                        if component.mode == .kinematic {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button {
                    component.mode = .dynamic
                } label: {
                    Label {
                        Text("Dynamic")
                    } icon: {
                        if component.mode == .dynamic {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", systemImage: "checkmark") {
//                    let shape: ShapeResource = .generateSphere(radius: 0.1)
//                    var component: PhysicsBodyComponent = .init(
//                        shapes: [shape],
//                        density: 10_000
//                    )
//                    
//                    component.isAffectedByGravity = true
//                    entity.components.set(component)
//                    entity.components.set(CollisionComponent(shapes: [shape]))
                    
                    entity.components.set(component)
                    realityService.popToEntitySettings()
                }
            }
        }
        .navigationTitle("PhysicsBodyComponent")
        .onChange(of: entity, initial: true) { _, newValue in
            let component: PhysicsBodyComponent
            if let _component = newValue.components[PhysicsBodyComponent.self] {
                component = _component
            } else {
                guard let modelEntity = newValue as? ModelEntity,
                      let model = modelEntity.model else {
                    fatalError("Cannot find MeshResource. (TODO: Please specify MeshResource)")
                }
                
                let material = model
                    .materials
                    .last { $0 is PhysicsMaterialResource } as? PhysicsMaterialResource
                
                let shape = ShapeResource.generateConvex(from: model.mesh)
//                component = PhysicsBodyComponent(
//                    massProperties: PhysicsMassProperties(shape: shape, density: 10_000),
//                    material: material,
//                    mode: .kinematic
//                )
                component = .init(
                                        shapes: [shape],
                                        density: 10_000
                                    )
            }
            
            self.component = component
        }
    }
}

//#Preview {
//    PhysicsBodyComponentView()
//}
