//
//  EntityPositionView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/15/25.
//

import SwiftUI
import RealityFoundation

struct EntityPositionView: View {
    @Environment(RealityService.self) private var realityService
    @State private var viewModel = EntityPositionViewModel()
    private let entity: Entity
    
    init(entity: Entity) {
        self.entity = entity
    }
    
    var body: some View {
        Group {
            let _ = viewModel.accessPosition()
            
            HStack {
                Text("X")
                
                Slider(
                    value: Binding<Float>(
                        get: {
                            entity.position.x
                        },
                        set: { newValue in
                            entity.position.x = newValue
                        }
                    ),
                    in: realityService.boundingBox.min.x...realityService.boundingBox.max.x
                )
            }
            
            HStack {
                Text("Y")
                
                Slider(
                    value: Binding<Float>(
                        get: {
                            entity.position.y
                        },
                        set: { newValue in
                            entity.position.y = newValue
                        }
                    ),
                    in: realityService.boundingBox.min.y...realityService.boundingBox.max.y
                )
            }
            
            HStack {
                Text("Z")
                
                Slider(
                    value: Binding<Float>(
                        get: {
                            entity.position.z
                        },
                        set: { newValue in
                            entity.position.z = newValue
                        }
                    ),
                    in: realityService.boundingBox.min.z...realityService.boundingBox.max.z
                )
            }
            
            Button("Center") { 
                entity.position = realityService.boundingBox.center
            }
        }
        .onChange(of: entity, initial: true) { _, newValue in
            viewModel.didChangeEntity(newValue)
        }
    }
}
