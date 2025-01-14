//
//  Entity_ComponentSet+Array.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/15/25.
//

import RealityFoundation

extension Entity.ComponentSet {
    var array: [any Component] {
        .init(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            for component in self {
                buffer.baseAddress!.advanced(by: initializedCount).initialize(to: component)
                initializedCount += 1
            }
        }
    }
}
