//
//  AddComponentView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import SwiftUI
import RealityKit

struct AddComponentView: View {
    @Environment(ContentViewModel.self) private var viewModel
    private let entity: Entity
    
    init(entity: Entity) {
        self.entity = entity
    }
    
    var body: some View {
        Form { 
            NavigationLink("PhysicsBodyComponent", value: ContentStack.addPhysicsBodyComponent(entity: entity))
        }
        .navigationTitle("Add Component")
    }
}

//#Preview {
//    AddComponentsView()
//}
