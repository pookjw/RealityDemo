//
//  PhysicsBodyComponentView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import SwiftUI
import RealityKit

struct PhysicsBodyComponentView: View {
    @Environment(ContentViewModel.self) private var viewModel
    private let entity: Entity
    
    init(entity: Entity) {
        self.entity = entity
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//#Preview {
//    PhysicsBodyComponentView()
//}
