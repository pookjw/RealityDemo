//
//  AddComponentView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import SwiftUI
import RealityKit

struct AddComponentView: View {
    @Environment(RealityService.self) private var realityService
    @State private var component = PhysicsBodyComponent()
    private let entity: Entity
    
    init(entity: Entity) {
        self.entity = entity
    }
    
    var body: some View {
        Form { 
            NavigationLink(_mangledTypeName(PhysicsBodyComponent.self)!, value: ContentStack.physicsBodyComponent(entity: entity))
            
            NavigationLink(_mangledTypeName(CollisionComponent.self)!, value: ContentStack.collisionComponent(entity: entity))
            
            NavigationLink(_mangledTypeName(ModelComponent.self)!, value: ContentStack.modelComponent(entity: entity))
        }
        .navigationTitle("Add Component")
    }
}

//#Preview {
//    AddComponentsView()
//}
