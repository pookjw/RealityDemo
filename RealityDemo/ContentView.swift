//
//  ContentView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(RealityService.self) private var realityService
    @State private var menuVisibility: Visibility = .visible
    
    var body: some View {
        GeometryReader3D { proxy in
            RealityView { (content: inout RealityViewContent, attachments: RealityViewAttachments) in
                realityService
                    .configureRealityView(
                        content: &content,
                        attachments: attachments,
                        boundingBox: bondingBox(content: &content, proxy: proxy)
                    )
            } update: { (content: inout RealityViewContent, attachments: RealityViewAttachments) in
                realityService
                    .updateRealityView(
                        content: &content,
                        attachments: attachments,
                        boundingBox: bondingBox(content: &content, proxy: proxy)
                    )
            } attachments: { 
                
            }
            .offset(z: -proxy.size.depth * 0.25)
            .ornament(
                visibility: .visible,
                attachmentAnchor: .scene(.bottomFront),
                contentAlignment: .top
            ) {
                toggleButton
            }
            .ornament(
                visibility: menuVisibility,
                attachmentAnchor: .scene(.trailingFront),
                contentAlignment: .leading
            ) {
                NavigationStack(
                    path: Binding<[ContentStack]>(
                        get: {
                            realityService.stack
                        },
                        set: { newValue in
                            realityService.stack = newValue
                        }
                    )
                ) {
                    EntitiesView()
                        .environment(realityService)
                        .navigationDestination(for: ContentStack.self) { value in
                            switch value {
                            case .entitySettings(let entity):
                                EntityView(entity: entity)
                            case .addComponent(let entity):
                                AddComponentView(entity: entity)
                            case .physicsBodyComponent(let entity):
                                PhysicsBodyComponentView(entity: entity)
                            case .collisionComponent(let entity):
                                CollisionComponentView(entity: entity)
                            case .modelComponent(let entity):
                                ModelComponentView(entity: entity)
                            case .faces:
                                FacesView()
                            }
                        }
                }
                .frame(width: 400.0, height: proxy.size.height)
            }
            .onChange(
                of: {
                    realityService.accessEntities()
                    return realityService.rootEntity.children.array
                }(),
                initial: true
            ) { _, newValue in
                var stack = realityService.stack
                var toBeRemovedIndices = IndexSet(integersIn: stack.indices)
                
                for index in 0..<stack.count {
                    let element = stack[index]
                    
                    guard let otherEntity = element.entity else {
                        toBeRemovedIndices.remove(index)
                        continue
                    }
                    
                    if realityService.rootEntity.children.contains(otherEntity) {
                        toBeRemovedIndices.remove(index)
                        continue
                    }
                }
                
                let sorted = Array(toBeRemovedIndices)
                    .sorted(by: >)
                
                for index in sorted {
                    stack.remove(at: index)
                }
                
                realityService.stack = stack
            }
        }
    }
    
    @ViewBuilder private var toggleButton: some View {
        Button("Menu", systemImage: "line.3.horizontal") { 
            withAnimation {
                switch menuVisibility {
                case .visible:
                    menuVisibility = .hidden
                default:
                    menuVisibility = .visible
                }
            }
        }
        .labelStyle(.iconOnly)
        .padding()
        .glassBackgroundEffect(in: .capsule, displayMode: .always)
    }
    
    private func bondingBox(content: inout RealityViewContent, proxy: GeometryProxy3D) -> BoundingBox {
        let localFrame: Rect3D = proxy.frame(in: .local)
        let sceneFrame: BoundingBox = content.convert(localFrame, from: .local, to: .scene)
        return sceneFrame
    }
}

#Preview {
    ContentView()
}
