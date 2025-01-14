//
//  EntitiesView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import SwiftUI

struct EntitiesView: View {
    @Environment(RealityService.self) private var realityService
    
    var body: some View {
        let _ = realityService.accessEntities()
        
        List(realityService.rootEntity.children.array) { entity in
            NavigationLink(entity.name, value: ContentStack.entitySettings(entity: entity))
                .swipeActions(
                    edge: .trailing,
                    allowsFullSwipe: true
                ) {
                    Button("Remove Entity", systemImage: "trash") {
                        realityService.mutateEntities {
                            realityService.rootEntity.removeChild(entity)
                        }
                    }
                    .tint(.red)
                }
        }
        .navigationTitle("Entities")
        .toolbar { 
            ToolbarItem(placement: .topBarTrailing) { 
                Button("Add Entity", systemImage: "plus") {
                    realityService.mutateEntities {
                        realityService.rootEntity.addChild(realityService.defaultEntity())
                    }
                }
            }
        }
    }
}

//#Preview {
//    EntitiesView()
//}
