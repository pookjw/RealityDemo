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
    @State private var currentEntity: Entity?
    private let entity: Entity
    
    init(entity: Entity) {
        self.entity = entity
    }
    
    var body: some View {
        Form {
            Section("Mode") {
                Button {
                    component.mode = .default
                } label: {
                    Label {
                        Text("Default")
                    } icon: {
                        if component.mode == .default {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button {
                    component.mode = .trigger
                } label: {
                    Label {
                        Text("Trigger")
                    } icon: {
                        if component.mode == .trigger {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button {
                    component.mode = .colliding
                } label: {
                    Label {
                        Text("Colliding")
                    } icon: {
                        if component.mode == .colliding {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            Section("filter") {
                NavigationLink("filter.group") {
                    CollisionGroupsView(selectedGroup: $component.filter.group)
                }
                
                NavigationLink("filter.mask") {
                    CollisionGroupsView(selectedGroup: $component.filter.mask)
                }
            }
            
            Text("shapes (TODO)")
        }
        .navigationTitle(_typeName(CollisionComponent.self))
        .toolbar {
            componentToolbarItems(entity: entity, component: component, realityService: realityService)
        }
        .onChange(of: entity, initial: true) { oldValue, newValue in
            guard currentEntity != newValue else { return }
            currentEntity = newValue
            
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
                    shapes: [shape],
                    mode: .colliding,
                    filter: .init(group: .default, mask: .default)
                )
            }
            
            self.component = component
        }
    }
}
