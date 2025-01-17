//
//  EntityView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import SwiftUI
import RealityKit

struct EntityView: View {
    @Environment(RealityService.self) private var realityService
    @State private var viewModel = EntityViewModel()
    private let entity: Entity
    
    init(entity: Entity) {
        self.entity = entity
    }
    
    var body: some View {
        Form {
            Section("Components") {
                let _ = viewModel.accessComponents()
                ForEach(entity.components.array, id: \.componentName) { component in
                    NavigationLink(component.componentName, value: stack(from: component))
                        .swipeActions(
                            edge: .trailing,
                            allowsFullSwipe: true
                        ) {
                            Button("Remove Component", systemImage: "trash") {
                                entity.components.remove(type(of: component))
                            }
                            .tint(.red)
                        }
                }
            }
            
            Section("Position") {
                EntityPositionView(entity: entity)
            }
        }
            .navigationTitle(entity.name)
            .toolbar { 
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Remove Entity", systemImage: "trash") {
                        realityService.rootEntity.removeChild(entity)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Component", systemImage: "plus") { 
                        realityService.stack.append(.addComponent(entity: entity))
                    }
                }
            }
            .onChange(of: entity, initial: true) { _, newValue in
                viewModel.didChangeEntity(newValue)
            }
        
    }
    
    private func stack(from component: any Component) -> ContentStack? {
        switch component {
        case is PhysicsBodyComponent:
            return .physicsBodyComponent(entity: entity)
        case is CollisionComponent:
            return .collisionComponent(entity: entity)
        case is ModelComponent:
            return .modelComponent(entity: entity)
        default:
            return nil
        }
    }
}

extension Component {
    fileprivate var componentName: String {
        Self.__typeName
//        String(describing: type(of: self))
    }
}

//#Preview {
//    EntityView()
//}
