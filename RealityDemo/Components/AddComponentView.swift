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
            NavigationLink("PhysicsBodyComponent", value: ContentStack.physicsBodyComponent(entity: entity))
            
            NavigationLink("CollisionComponent", value: ContentStack.collisionComponent(entity: entity))
            
            NavigationLink("ModelComponent", value: ContentStack.modelComponent(entity: entity))
        }
        .navigationTitle("Add Component")
    }
}

//#Preview {
//    AddComponentsView()
//}
