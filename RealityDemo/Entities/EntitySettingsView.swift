//
//  EntitySettingsView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import SwiftUI
import RealityKit

struct EntitySettingsView: View {
    @Environment(RealityService.self) private var realityService
    private let entity: Entity
    
    init(entity: Entity) {
        self.entity = entity
    }
    
    var body: some View {
        Form {
            Section("Components") {
                
            }
        }
            .navigationTitle(entity.name)
            .toolbar { 
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Remove Entity", systemImage: "trash") {
                        realityService.mutateEntities {
                            realityService.rootEntity.removeChild(entity)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Component", systemImage: "plus") { 
                        realityService.stack.append(.addComponent(entity: entity))
                    }
                }
            }
    }
}

//#Preview {
//    EntitySettingsView()
//}
