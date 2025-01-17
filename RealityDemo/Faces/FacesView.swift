//
//  FacesView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/17/25.
//

import SwiftUI
import RealityFoundation

struct FacesView: View {
    @Environment(RealityService.self) private var realityService
    
    var body: some View {
        List(Face.allCases) { face in
            Button(face.rawValue) {
                if let entity = realityService.faceEntity(for: face) {
                    realityService.stack.append(.entitySettings(entity: entity))
                }
            }
        }
    }
}

#Preview {
    FacesView()
}
