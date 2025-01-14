//
//  Entity_ChildCollection+Array.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/15/25.
//

import RealityFoundation

extension Entity.ChildCollection {
    var array: [Entity] {
        .init(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            for entity in self {
                buffer.baseAddress!.advanced(by: initializedCount).initialize(to: entity)
                initializedCount += 1
            }
        }
    }
}
