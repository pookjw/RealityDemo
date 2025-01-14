//
//  EntitySettingsView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import SwiftUI
import RealityKit

struct EntitySettingsView: View {
    @Environment(ContentViewModel.self) private var viewModel
    private let entity: Entity
    
    init(entity: Entity) {
        self.entity = entity
    }
    
    var body: some View {
        Form {
            Section("Components") { 
                Label("Foo", systemImage: "xmark")
            }
        }
            .navigationTitle(entity.name)
            .toolbar { 
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Remove Entity", systemImage: "trash") {
                        viewModel.removeEntity(entity)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Component", systemImage: "plus") { 
                        viewModel.stack.append(.addComponent(entity: entity))
                    }
                }
            }
    }
}

//#Preview {
//    EntitySettingsView()
//}
