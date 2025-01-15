//
//  CollisionComponentView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/15/25.
//

import SwiftUI
import RealityFoundation

struct CollisionComponentView: View {
    @Environment(RealityService.self) private var realityService
    @State private var component = CollisionComponent(shapes: [])
    private let entity: Entity
    
    init(entity: Entity) {
        self.entity = entity
    }
    
    var body: some View {
        Form {
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", systemImage: "checkmark") {
                    entity.components.set(component)
                    realityService.popToEntitySettings()
                }
            }
        }
        .onChange(of: entity, initial: true) { _, newValue in
            let component: CollisionComponent
            if let _component = newValue.components[CollisionComponent.self] {
                component = _component
            } else {
                guard let modelEntity = newValue as? ModelEntity,
                      let model = modelEntity.model else {
                    fatalError("Cannot find MeshResource. (TODO: Please specify MeshResource)")
                }
                
                let shape = ShapeResource.generateConvex(from: model.mesh)
                
                component = CollisionComponent(
                    shapes: [shape]
                )
            }
            
            self.component = component
        }
    }
}
