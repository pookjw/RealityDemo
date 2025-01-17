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
            
            HStack {
                Text("boundsMargin")
                Slider(value: $component.boundsMargin, in: -1.0...1.0)
            }
        }
            .toolbar {
                componentToolbarItems(entity: entity, component: component, realityService: realityService)
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
    fileprivate static var defaultComponent: ModelComponent {
        ModelComponent(
            mesh: MeshResource.generateBox(size: .init(x: 0.1, y: 0.1, z: 0.1)),
            materials: [
                SimpleMaterial(color: .init(white: .zero, alpha: 1.0), isMetallic: true)
            ]
        )
    }
}