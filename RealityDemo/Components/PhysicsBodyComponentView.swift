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
                
                HStack {
                    Text("inertia.x")
                    Slider(value: $wrapper.component.massProperties.inertia.x, in: 0.0...maxInertia.x)
                }
                
                HStack {
                    Text("inertia.y")
                    Slider(value: $wrapper.component.massProperties.inertia.y, in: 0.0...maxInertia.y)
                }
                
                HStack {
                    Text("inertia.z")
                    Slider(value: $wrapper.component.massProperties.inertia.z, in: 0.0...maxInertia.z)
                }
                
                HStack {
                    Text("centerOfMass.position.x")
                    Slider(value: $wrapper.component.massProperties.centerOfMass.position.x, in: realityService.boundingBox.min.x...realityService.boundingBox.max.x)
                }
                
                HStack {
                    Text("centerOfMass.position.y")
                    Slider(value: $wrapper.component.massProperties.centerOfMass.position.y, in: realityService.boundingBox.min.y...realityService.boundingBox.max.y)
                }
                
                HStack {
                    Text("centerOfMass.position.z")
                    Slider(value: $wrapper.component.massProperties.centerOfMass.position.z, in: realityService.boundingBox.min.z...realityService.boundingBox.max.z)
                }
                
                HStack {
                    Text("centerOfMass.orientation.angle")
                    Slider(
                        value: Binding<Float>(
                            get: {
                                wrapper.component.massProperties.centerOfMass.orientation.angle
                            },
                            set: { newValue in
                                let orientation = wrapper.component.massProperties.centerOfMass.orientation
                                wrapper.component.massProperties.centerOfMass.orientation = simd_quatf(angle: newValue, axis: orientation.axis)
                            }
                        ),
                        in: 0.0...(Float.pi * 2.0)
                    )
                }
                
                HStack {
                    Text("centerOfMass.orientation.axis.x")
                    Slider(
                        value: Binding<Float>(
                            get: {
                                wrapper.component.massProperties.centerOfMass.orientation.axis.x
                            },
                            set: { newValue in
                                let orientation = wrapper.component.massProperties.centerOfMass.orientation
                                var axis = orientation.axis
                                axis.x = newValue
                                wrapper.component.massProperties.centerOfMass.orientation = simd_quatf(angle: orientation.angle, axis: axis)
                            }
                        ),
                        in: -1.0...1.0
                    )
                }
                
                HStack {
                    Text("centerOfMass.orientation.axis.y")
                    Slider(
                        value: Binding<Float>(
                            get: {
                                wrapper.component.massProperties.centerOfMass.orientation.axis.y
                            },
                            set: { newValue in
                                let orientation = wrapper.component.massProperties.centerOfMass.orientation
                                var axis = orientation.axis
                                axis.y = newValue
                                wrapper.component.massProperties.centerOfMass.orientation = simd_quatf(angle: orientation.angle, axis: axis)
                            }
                        ),
                        in: -1.0...1.0
                    )
                }
                
                HStack {
                    Text("centerOfMass.orientation.axis.z")
                    Slider(
                        value: Binding<Float>(
                            get: {
                                wrapper.component.massProperties.centerOfMass.orientation.axis.z
                            },
                            set: { newValue in
                                let orientation = wrapper.component.massProperties.centerOfMass.orientation
                                var axis = orientation.axis
                                axis.z = newValue
                                wrapper.component.massProperties.centerOfMass.orientation = simd_quatf(angle: orientation.angle, axis: axis)
                            }
                        ),
                        in: -1.0...1.0
                    )
                }
            }
        }
        .toolbar {
            componentToolbarItems(entity: entity, component: wrapper.component, realityService: realityService)
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
        .onChange(of: wrapper.component.massProperties.mass, initial: true) { _, _ in
            wrapper.component.massProperties.inertia.x = min(wrapper.component.massProperties.inertia.x, maxInertia.x)
            wrapper.component.massProperties.inertia.y = min(wrapper.component.massProperties.inertia.y, maxInertia.x)
            wrapper.component.massProperties.inertia.z = min(wrapper.component.massProperties.inertia.z, maxInertia.x)
        }
    }
    
    private var maxInertia: SIMD3<Float> {
        guard let boundingBox = (entity as? ModelEntity)?.model?.mesh.bounds else {
            return SIMD3<Float>(x: 30.0, y: 30.0, z: 30.0)
        }
        
        // I = m * (r ^ 2)
        return SIMD3<Float>(
            x: wrapper.component.massProperties.mass * pow(boundingBox.max.x - boundingBox.min.x, 2),
            y: wrapper.component.massProperties.mass * pow(boundingBox.max.y - boundingBox.min.y, 2),
            z: wrapper.component.massProperties.mass * pow(boundingBox.max.z - boundingBox.min.z, 2)
        )
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
