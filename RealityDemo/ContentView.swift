//
//  ContentView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var menuVisibility: Visibility = .visible
    @State private var viewModel = ContentViewModel()
    
    var body: some View {
        GeometryReader3D { proxy in
            RealityView { (content: inout RealityViewContent, attachments: RealityViewAttachments) in
                viewModel
                    .configureRealityView(
                        content: &content,
                        attachments: attachments,
                        boundingBox: bondingBox(content: &content, proxy: proxy)
                    )
            } update: { (content: inout RealityViewContent, attachments: RealityViewAttachments) in
                viewModel
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
                NavigationStack(path: $viewModel.stack) { 
                    EntitiesView()
                        .environment(viewModel)
                        .navigationDestination(for: ContentStack.self) { value in
                            Group {
                                switch value {
                                case .entitySettings(let entity):
                                    EntitySettingsView(entity: entity)
                                case .addComponent(let entity):
                                    AddComponentView(entity: entity)
                                case .addPhysicsBodyComponent(let entity):
                                    PhysicsBodyComponentView(entity: entity)
                                }
                            }
                            .environment(viewModel)
                        }
                }
                .frame(width: 400.0, height: proxy.size.height)
            }
            .onChange(of: viewModel.entities, initial: true) { _, newValue in
                var stack = viewModel.stack
                var toBeRemovedIndices = IndexSet(integersIn: stack.indices)
                
                for entity in newValue {
                    for index in stack.indices {
                        if stack[index].entity == entity {
                            toBeRemovedIndices.remove(index)
                            break
                        }
                    }
                }
                
                let sorted = Array(toBeRemovedIndices)
                    .sorted(by: >)
                
                for index in sorted {
                    stack.remove(at: index)
                }
                
                viewModel.stack = stack
            }
            .onAppear { 
                viewModel.stack.append(.entitySettings(entity: viewModel.addEntity()))
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
