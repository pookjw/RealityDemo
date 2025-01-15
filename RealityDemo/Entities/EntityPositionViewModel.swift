//
//  EntityPositionViewModel.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/15/25.
//

import RealityFoundation
import Combine
import Observation

@MainActor
@Observable
final class EntityPositionViewModel {
    private var entity: Entity?
    private var sceneUpdateCancellable: (any Cancellable)?
    private let positionObservationToken: Void = ()
    
    func didChangeEntity(_ entity: Entity) {
        self.entity = entity
        
        guard let scene = entity.scene else {
            fatalError()
        }
        
        sceneUpdateCancellable = scene
            .subscribe(to: SceneEvents.Update.self) { [weak self] event in
                self?.withMutation(keyPath: \.positionObservationToken, {})
            }
    }
    
    func accessPosition() {
        access(keyPath: \.positionObservationToken)
    }
}
