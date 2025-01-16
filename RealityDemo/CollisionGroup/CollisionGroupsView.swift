//
//  CollisionGroupsView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/16/25.
//

import SwiftUI
import RealityFoundation

struct CollisionGroupsView: View {
    @Environment(RealityService.self) private var realityService
    @Binding private var selectedGroup: CollisionGroup
    
    init(selectedGroup: Binding<CollisionGroup>) {
        _selectedGroup = selectedGroup
    }
    
    var body: some View {
        List(
            realityService
                .collisionGroups
                .keys
                .sorted(using: KeyPathComparator(\.rawValue, order: .forward)),
            id: \.rawValue
        ) { collisionGroup in
            Button {
                if selectedGroup.contains(collisionGroup) {
                    selectedGroup.remove(collisionGroup)
                } else {
                    selectedGroup.formUnion(collisionGroup)
                }
            } label: {
                Label {
                    Text(realityService.collisionGroups[collisionGroup]!)
                        .foregroundColor(collisionGroup.isProtected ? .secondary : nil)
                } icon: {
                    if selectedGroup.contains(collisionGroup) {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .navigationTitle(realityService.collisionGroups.count.description)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Collision Group", systemImage: "plus") {
                    let allCollisionGroup = realityService
                        .collisionGroups
                        .keys
                        .filter { $0 != .all }
                        .reduce(CollisionGroup(rawValue: .zero)) { partialResult, next in
                            partialResult.union(next)
                        }
                    
                    var newCollisionGroupRawValue: UInt32 = 1 << 0
                    while allCollisionGroup.contains(CollisionGroup(rawValue: newCollisionGroupRawValue)) {
                        newCollisionGroupRawValue = newCollisionGroupRawValue << 1
                        assert(newCollisionGroupRawValue != .zero)
                    }
                    
                    realityService.collisionGroups[CollisionGroup(rawValue: newCollisionGroupRawValue)] = Date.now.description
                }
                .disabled({
                    let allCollisionGroup = realityService
                        .collisionGroups
                        .keys
                        .filter { $0 != .all }
                        .reduce(CollisionGroup(rawValue: .zero)) { partialResult, next in
                            partialResult.union(next)
                        }
                    
                    return CollisionGroup(rawValue: .max >> 1).intersection(allCollisionGroup) == CollisionGroup(rawValue: .max >> 1)
                }())
            }
        }
    }
}

extension CollisionGroup {
    fileprivate var isProtected: Bool {
        self == .default || self == .sceneUnderstanding || self == .all
    }
}
