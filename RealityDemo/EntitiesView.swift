//
//  EntitiesView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import SwiftUI

struct EntitiesView: View {
    @Environment(ContentViewModel.self) private var viewModel
    
    var body: some View {
        List(viewModel.entities) { entity in
            NavigationLink(entity.name, value: ContentStack.entitySettings(entity: entity))
                .swipeActions(
                    edge: .trailing,
                    allowsFullSwipe: true
                ) { 
                    Button("Remove Entity", systemImage: "trash") { 
                        viewModel.removeEntity(entity)
                    }
                    .tint(.red)
                }
        }
        .navigationTitle("Entities")
        .toolbar { 
            ToolbarItem(placement: .topBarTrailing) { 
                Button("Add Entity", systemImage: "plus") { 
                    viewModel.addEntity()
                }
            }
        }
    }
}

//#Preview {
//    EntitiesView()
//}
