//
//  ViewUpdater.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/19/25.
//

import Observation

@MainActor
@Observable
final class ViewUpdater {
    private let token: Void = ()
    
    func regisger() {
        access(keyPath: \.token)
    }
    
    func update() {
        withMutation(keyPath: \.token, {})
    }
}
