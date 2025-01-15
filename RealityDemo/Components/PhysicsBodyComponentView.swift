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
    @State private var wrapper = PhysicsBodyComponentWrapper(component: PhysicsBodyComponent())
    private let entity: Entity
    
    init(entity: Entity) {
        self.entity = entity
    }
    
    var body: some View {
        Form {
            Toggle("isContinuousCollisionDetectionEnabled", isOn: $wrapper.component.isContinuousCollisionDetectionEnabled)
            
            Section("isRotationLocked") {
                Toggle("X", isOn: $wrapper.component.isRotationLocked.x)
                Toggle("Y", isOn: $wrapper.component.isRotationLocked.y)
                Toggle("Z", isOn: $wrapper.component.isRotationLocked.z)
            }
            
            Section("isTranslationLocked") {
                Toggle("X", isOn: $wrapper.component.isTranslationLocked.x)
                Toggle("Y", isOn: $wrapper.component.isTranslationLocked.y)
                Toggle("Z", isOn: $wrapper.component.isTranslationLocked.z)
            }
            
            Section("PhysicsBodyMode") {
                Button {
                    wrapper.component.mode = .static
                } label: {
                    Label {
                        Text("Static")
                    } icon: {
                        if wrapper.component.mode == .static {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button {
                    wrapper.component.mode = .kinematic
                } label: {
                    Label {
                        Text("Kinematic")
                    } icon: {
                        if wrapper.component.mode == .kinematic {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button {
                    wrapper.component.mode = .dynamic
                } label: {
                    Label {
                        Text("Dynamic")
                    } icon: {
                        if wrapper.component.mode == .dynamic {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            Section {
                Toggle("isAffectedByGravity", isOn: $wrapper.component.isAffectedByGravity)
            }
            
            Section {
                HStack {
                    Text("angularDamping")
                    Slider(value: $wrapper.component.angularDamping, in: 0.0...20.0)
                }
                
                HStack {
                    Text("linearDamping")
                    Slider(value: $wrapper.component.linearDamping, in: 0.0...20.0)
                }
            }
            
            Section("massProperties") {
                HStack {
                    Text("mass (kilograms)")
                    Slider(value: $wrapper.component.massProperties.mass, in: 0.0...100.0)
                }
                
#warning("TODO")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", systemImage: "checkmark") {
                    entity.components.set(wrapper.component)
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
                component = PhysicsBodyComponent(
                    massProperties: PhysicsMassProperties(shape: shape, mass: 50),
                    material: material,
                    mode: .dynamic
                )
            }
            
            wrapper = PhysicsBodyComponentWrapper(component: component)
        }
    }
}

fileprivate struct PhysicsBodyComponentWrapper: Equatable {
    static func ==(lhs: PhysicsBodyComponentWrapper, rhs: PhysicsBodyComponentWrapper) -> Bool {
        (lhs.component == rhs.component) &&
        (lhs.component.isAffectedByGravity == rhs.component.isAffectedByGravity) &&
        (lhs.component.angularDamping == rhs.component.angularDamping) &&
        (lhs.component.linearDamping == rhs.component.linearDamping) &&
        (lhs.component.massProperties == rhs.component.massProperties)
    }
    
    var component: PhysicsBodyComponent
}

//#Preview {
//    PhysicsBodyComponentView()
//}
