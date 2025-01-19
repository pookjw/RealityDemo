//
//  EntityViewModel.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/15/25.
//

import Observation
import RealityFoundation
import Combine

@MainActor
@Observable
final class EntityViewModel {
    @ObservationIgnored private(set) var entity: Entity?
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    
    private let componentsObservationKey: Void = ()
    
    func didChangeEntity(_ entity: Entity) {
        self.entity = entity
        
        guard let scene = entity.scene else {
            fatalError()
        }
        
        var cancellables = Set<AnyCancellable>(minimumCapacity: 5)
        
        scene
            .subscribe(to: ComponentEvents.DidAdd.self, on: entity) { [weak self] event in
                self?.withMutation(keyPath: \.componentsObservationKey, {})
            }
            .store(in: &cancellables)
        
        scene
            .subscribe(to: ComponentEvents.WillRemove.self, on: entity) { [weak self] event in
                self?.withMutation(keyPath: \.componentsObservationKey, {})
            }
            .store(in: &cancellables)
        
        scene
            .subscribe(to: ComponentEvents.DidChange.self, on: entity) { [weak self] event in
                self?.withMutation(keyPath: \.componentsObservationKey, {})
            }
            .store(in: &cancellables)
        
        scene
            .subscribe(to: ComponentEvents.DidActivate.self, on: entity) { [weak self] event in
                self?.withMutation(keyPath: \.componentsObservationKey, {})
            }
            .store(in: &cancellables)
        
        scene
            .subscribe(to: ComponentEvents.WillDeactivate.self, on: entity) { [weak self] event in
                self?.withMutation(keyPath: \.componentsObservationKey, {})
            }
            .store(in: &cancellables)
        
        self.cancellables = cancellables
        
        withMutation(keyPath: \.componentsObservationKey, {})
    }
}

extension EntityViewModel {
    func accessComponents() {
        access(keyPath: \.componentsObservationKey)
    }
}
