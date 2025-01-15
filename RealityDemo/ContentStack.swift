//
//  ContentStack.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import RealityFoundation

enum ContentStack: Hashable {
    case entitySettings(entity: Entity)
    case addComponent(entity: Entity)
    case physicsBodyComponent(entity: Entity)
    case collisionComponent(entity: Entity)
    
    var entity: Entity? {
        switch self {
        case .entitySettings(let entity):
            return entity
        case .addComponent(let entity):
            return entity
        case .physicsBodyComponent(let entity):
            return entity
        case .collisionComponent(let entity):
            return entity
        }
    }
}
