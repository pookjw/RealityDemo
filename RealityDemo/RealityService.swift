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
import Combine

@Observable
@MainActor
final class RealityService {
    var stack: [ContentStack] = []
    let rootEntity = Entity()
    private(set) var boundingBox = BoundingBox()
    
    var collisionGroups: [CollisionGroup: String] = [
        .default: "Default",
        .all: "All",
        .sceneUnderstanding: "Scene Understanding"
    ]
    
    private let boundingBoxEntity = Entity()
    private let entitiesObservationKey: Void = ()
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    
    func configureRealityView(content: inout RealityViewContent, attachments: RealityViewAttachments, boundingBox: BoundingBox) {
        let rootEntity = rootEntity
        
        assert(rootEntity.parent == nil)
        content.add(rootEntity)
        
        assert(boundingBoxEntity.parent == nil)
        content.add(boundingBoxEntity)
        
        RealityService.updateBoundingBoxEntity(boundingBoxEntity, boundingBox: boundingBox)
        
        guard let scene = rootEntity.scene ?? (Mirror(reflecting: content).descendant("scene") as? Scene) else {
            fatalError()
        }
        
        var cancellables = Set<AnyCancellable>(minimumCapacity: 5)
        
        scene
            .subscribe(to: SceneEvents.DidAddEntity.self) { [weak self] event in
                guard event.entity.parent == rootEntity else {
                    return
                }
                
                self?.withMutation(keyPath: \.entitiesObservationKey, {})
            }
            .store(in: &cancellables)
        
        scene
            .subscribe(to: SceneEvents.WillRemoveEntity.self) { [weak self] event in
                guard event.entity.parent == rootEntity else {
                    return
                }
                
                self?.withMutation(keyPath: \.entitiesObservationKey, {})
            }
            .store(in: &cancellables)
        
        self.cancellables = cancellables
        
        self.boundingBox = boundingBox
        
        
        // DEBUG
        let entity = defaultEntity()
        rootEntity.addChild(entity)
        stack = [
            .modelComponent(entity: entity)
//            .entitySettings(entity: entity),
//            .collisionComponent(entity: entity)
//            .physicsBodyComponent(entity: entity)
        ]
    }
    
    func updateRealityView(content: inout RealityViewContent, attachments: RealityViewAttachments, boundingBox: BoundingBox) {
        assert(rootEntity.parent != nil)
        assert(boundingBoxEntity.parent != nil)
        
        RealityService.updateBoundingBoxEntity(boundingBoxEntity, boundingBox: boundingBox)
        self.boundingBox = boundingBox
    }
    
    func popToEntitySettings() {
        stack = stack
            .filter { stack in
                switch stack {
                case .entitySettings:
                    return true
                default:
                    return false
                }
            }
    }
    
    func faceEntity(for face: Face) -> Entity? {
        boundingBoxEntity.findEntity(named: face.rawValue)
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
        
        //
        
        let material = entity
            .model!
            .materials
            .last { $0 is PhysicsMaterialResource } as? PhysicsMaterialResource
        
        let shape = ShapeResource.generateConvex(from: entity.model!.mesh)
        
        var physicsBodyComponent = PhysicsBodyComponent(
            massProperties: PhysicsMassProperties(shape: shape, mass: 100),
            material: material,
            mode: .dynamic
        )
        physicsBodyComponent.isAffectedByGravity = true
        
        entity.components.set(physicsBodyComponent)
        
        //
        
        let collisionComponent = CollisionComponent(
            shapes: [shape],
            mode: .colliding,
            filter: .init(group: .default, mask: .default)
        )
        entity.components.set(collisionComponent)
        
        //
        
        let hoverEffectComponent = HoverEffectComponent()
        entity.components.set(hoverEffectComponent)
        
        //
        
        let inputTargetComponent = InputTargetComponent()
        entity.components.set(inputTargetComponent)
        
        //
        
        return entity
    }
    
    func accessEntities() {
        access(keyPath: \.entitiesObservationKey)
    }
    
    private static func updateBoundingBoxEntity(_ boxEntity: Entity, boundingBox: BoundingBox) {
        let min: SIMD3<Float> = boundingBox.min
        let max: SIMD3<Float> = boundingBox.max
        let center: SIMD3<Float> = boundingBox.center
        
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
            
//            let collisionComponent = CollisionComponent(
//                shapes: [boxShape],
//                isStatic: true, // collider이 고정인지 아닌지 - 고정이라면 true로 하면 성능에 좋아질 것
//                filter: .sensor
//            )
            let collisionComponent = CollisionComponent(
                shapes: [boxShape],
                mode: .colliding,
                filter: .init(group: .default, mask: .default)
            )
            
            var physicsBodyComponent = PhysicsBodyComponent(
                shapes: [boxShape],
                mass: 1.0,
                material: nil,
                mode: .static // 벽은 움직이지 않는다.
            )
            physicsBodyComponent.isAffectedByGravity = false
            
            let faceEntity: ModelEntity
            if let _faceEntity = boxEntity.findEntity(named: face.rawValue) {
                faceEntity = _faceEntity as! ModelEntity
            } else {
                faceEntity = ModelEntity()
                faceEntity.name = face.rawValue
                
                boxEntity.addChild(faceEntity)
            }
            
            faceEntity.components.set(collisionComponent)
            faceEntity.components.set(physicsBodyComponent)
            
            faceEntity.position = position
            faceEntity.model = ModelComponent(
                mesh: MeshResource.generateBox(size: size),
                materials: [
                    SimpleMaterial(color: .init(white: 1.0, alpha: 0.1), isMetallic: true)
                ]
            )
        }
    }
}
