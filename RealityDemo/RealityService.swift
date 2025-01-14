//
//  RealityService.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import Observation
import RealityFoundation
import _RealityKit_SwiftUI
import Foundation

@Observable
@MainActor
final class RealityService {
    var stack: [ContentStack] = []
    let rootEntity = Entity()
    private let boundingBoxEntity = Entity()
    private let entitiesObservationKey: Void = ()
    
    func configureRealityView(content: inout RealityViewContent, attachments: RealityViewAttachments, boundingBox: BoundingBox) {
        assert(rootEntity.parent == nil)
        content.add(rootEntity)
        
        assert(boundingBoxEntity.parent == nil)
        content.add(boundingBoxEntity)
        
        RealityService.updateBoundingBoxEntity(boundingBoxEntity, boundingBox: boundingBox)
    }
    
    func updateRealityView(content: inout RealityViewContent, attachments: RealityViewAttachments, boundingBox: BoundingBox) {
        assert(rootEntity.parent != nil)
        assert(boundingBoxEntity.parent != nil)
        
        RealityService.updateBoundingBoxEntity(boundingBoxEntity, boundingBox: boundingBox)
    }
}

extension RealityService {
    func defaultEntity() -> Entity {
        let entity = ModelEntity()
        
        entity.name = Date.now.description
        
        entity.model = ModelComponent(
            mesh: MeshResource.generateBox(size: .init(x: 0.1, y: 0.1, z: 0.1)),
            materials: [
                SimpleMaterial(color: .init(white: .zero, alpha: 1.0), isMetallic: true)
            ]
        )
        
        return entity
    }
    
    func mutateEntities(_ block: () throws -> Void) rethrows {
        let oldChildrenArray = rootEntity.children.array
        try block()
        let newChildrenArray = rootEntity.children.array
        
        if oldChildrenArray != newChildrenArray {
            withMutation(keyPath: \.entitiesObservationKey, {})
        }
    }
    
    func accessEntities() {
        access(keyPath: \.entitiesObservationKey)
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
