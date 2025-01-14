//
//  ContentViewModel.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import Observation
import RealityKit
import _RealityKit_SwiftUI
import Foundation

@Observable
@MainActor
final class ContentViewModel {
    var stack: [ContentStack] = []
    private(set) var entities: [Entity] = []
    @ObservationIgnored private var boundingBoxEntity: Entity?
    
    init() {
        
    }
    
    func configureRealityView(content: inout RealityViewContent, attachments: RealityViewAttachments, boundingBox: BoundingBox) {
        assert(boundingBoxEntity == nil)
        
        let boundingBoxEntity = Entity()
        self.boundingBoxEntity = boundingBoxEntity
        content.add(boundingBoxEntity)
        
        updateRealityView(content: &content, attachments: attachments, boundingBox: boundingBox)
    }
    
    func updateRealityView(content: inout RealityViewContent, attachments: RealityViewAttachments, boundingBox: BoundingBox) {
        guard let boundingBoxEntity else {
            fatalError()
        }
        
        
        ContentViewModel.updateBoundingBoxEntity(boundingBoxEntity, boundingBox: boundingBox)
        access(keyPath: \.entities)
        
        var toBeAdded: [Entity] = []
        var toBeRemoved: [Entity] = []
        
        for entity in _entities {
            if !content.entities.contains(entity) {
                toBeAdded.append(entity)
            }
        }
        
        for entity in content.entities {
            if entity != boundingBoxEntity, !_entities.contains(entity) {
                toBeRemoved.append(entity)
            }
        }
        
        for entity in toBeRemoved {
            content.entities.remove(entity)
        }
        
        content.entities.append(contentsOf: toBeAdded)
    }
    
    @discardableResult
    func addEntity(name: String = Date().description) -> Entity {
        let entity = ModelEntity()
        
        entity.name = name
        
        entity.model = ModelComponent(
            mesh: MeshResource.generateBox(size: .init(x: 0.1, y: 0.1, z: 0.1)),
            materials: [
                SimpleMaterial(color: .init(white: .zero, alpha: 1.0), isMetallic: true)
            ]
        )
        
        entities.append(entity)
        return entity
    }
    
    func removeEntity(_ entity: Entity) {
        guard let firstIndex = _entities.firstIndex(of: entity) else {
            fatalError()
        }
        
        entities.remove(at: firstIndex)
    }
    
    private static func updateBoundingBoxEntity(_ boxEntity: Entity, boundingBox: BoundingBox) {
        boxEntity.children.removeAll()
        
        let min: SIMD3<Float> = boundingBox.min
        let max: SIMD3<Float> = boundingBox.max
        let center: SIMD3<Float> = boundingBox.center
        
        /*
           +---------------+
          /|              /|
         / |     4       / |
         +--------------+  |
         | |            |  |
         |1|      5     | 2|
         | |            |  |
         | |    6       |  |
         | +------------|--+
         |/      3      | /
         +--------------+/
         
           y+
           |
           +- x+
          /
         z+
         
         lHandFace : 1
         rHandFace : 2
         lowerFace : 3
         upperFace : 4
         nearFace : 5
         afarFace : 6
         */
        enum Face: CaseIterable {
            case lHandFace, rHandFace, lowerFace, upperFace, nearFace, afarFace
        }
        
        for face in Face.allCases {
            let thickness: Float = 1E-3
            let position: SIMD3<Float>
            let size: SIMD3<Float>
            switch face {
            case .lHandFace:
                position = SIMD3<Float>(x: min.x, y: center.y, z: center.z)
                size = SIMD3<Float>(x: thickness, y: boundingBox.extents.y, z: boundingBox.extents.z)
            case .rHandFace:
                position = SIMD3<Float>(x: max.x, y: center.y, z: center.z)
                size = SIMD3<Float>(x: thickness, y: boundingBox.extents.y, z: boundingBox.extents.z)
            case .lowerFace:
                position = SIMD3<Float>(x: center.x, y: min.y, z: center.z)
                size = SIMD3<Float>(x: boundingBox.extents.x, y: thickness, z: boundingBox.extents.z)
            case .upperFace:
                position = SIMD3<Float>(x: center.x, y: max.y, z: center.z)
                size = SIMD3<Float>(x: boundingBox.extents.x, y: thickness, z: boundingBox.extents.z)
            case .nearFace:
                position = SIMD3<Float>(x: center.x, y: center.y, z: min.z)
                size = SIMD3<Float>(x: boundingBox.extents.x, y: boundingBox.extents.y, z: thickness)
            case .afarFace:
                position = SIMD3<Float>(x: center.x, y: center.y, z: max.z)
                size = SIMD3<Float>(x: boundingBox.extents.x, y: boundingBox.extents.y, z: thickness)
            }
            
            let boxShape = ShapeResource.generateBox(size: size)
            
            let collisionComponent = CollisionComponent(
                shapes: [boxShape],
                isStatic: true, // collider이 고정인지 아닌지 - 고정이라면 true로 하면 성능에 좋아질 것
                filter: .sensor
            )
            
            var physicsBodyComponent = PhysicsBodyComponent(
                shapes: [boxShape],
                mass: 1.0,
                material: nil,
                mode: .static // 벽은 움직이지 않는다.
            )
            physicsBodyComponent.isAffectedByGravity = false
            
            let wallEntity = ModelEntity(components: [collisionComponent, physicsBodyComponent])
            wallEntity.position = position
            wallEntity.model = ModelComponent(
                mesh: MeshResource.generateBox(size: size),
                materials: [
                    SimpleMaterial(color: .init(white: 1.0, alpha: 0.1), isMetallic: true)
                ]
            )
            
            boxEntity.addChild(wallEntity)
        }
    }
}

extension ContentViewModel {
    @discardableResult
    func addPhysicsBodyComponent() -> PhysicsBodyComponent {
        fatalError()
    }
}
