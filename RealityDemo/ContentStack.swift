//
//  ContentStack.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import RealityKit

enum ContentStack: Hashable {
    case entitySettings(entity: Entity)
    case addComponent(entity: Entity)
    case addPhysicsBodyComponent(entity: Entity)
    
    var entity: Entity? {
        switch self {
        case .entitySettings(let entity):
            return entity
        case .addComponent(let entity):
            return entity
        case .addPhysicsBodyComponent(let entity):
            return entity
        }
    }
}
