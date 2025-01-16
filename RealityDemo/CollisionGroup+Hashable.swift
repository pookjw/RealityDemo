//
//  CollisionGroup+Hashable.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/16/25.
//

import RealityFoundation

extension CollisionGroup: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
