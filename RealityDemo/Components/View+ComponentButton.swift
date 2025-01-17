//
//  View+ComponentButton.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/16/25.
//

import SwiftUI
import RealityFoundation

extension View {
    @ToolbarContentBuilder
    func componentToolbarItems(
        entity: Entity,
        component: any Component,
        realityService: RealityService,
        placement: ToolbarItemPlacement = .topBarTrailing
    ) -> some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button("Remove Component", systemImage: "trash") {
                entity.components.remove(type(of: component))
                realityService.popToEntitySettings()
            }
            .labelStyle(.iconOnly)
        }
        
        ToolbarItem(placement: placement) {
            Button("Done", systemImage: "checkmark") {
                entity.components.set(component)
                realityService.popToEntitySettings()
            }
            .labelStyle(.iconOnly)
        }
    }
}
