//
//  OcclusionMaterialView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/19/25.
//

import SwiftUI
import RealityFoundation

struct OcclusionMaterialView: View {
    @Binding private var material: OcclusionMaterial
    private let completionHandler: (() -> Void)?
    @State private var pop = false
    
    init(
        material: Binding<OcclusionMaterial>,
        completionHandler: (() -> Void)? = nil
    ) {
        _material = material
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        Form {
            Section {
                Toggle("Reads Depth", isOn: $material.readsDepth)
            }
            
            Section("Face Culling") {
                ForEach(SimpleMaterial.FaceCulling.allCases) { faceCulling in
                    Button {
                        material.faceCulling = faceCulling
                    } label: {
                        Label {
                            Text(faceCulling.title)
                        } icon: {
                            if material.faceCulling == faceCulling {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            Image("occlusionmaterial-not-applied~dark")
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            Image("occlusionmaterial-applied~dark")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .navigationTitle(_typeName(OcclusionMaterial.self))
        .toolbar {
            if let completionHandler {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", systemImage: "checkmark") {
                        completionHandler()
                        pop = true
                    }
                }
            }
        }
        .pop(pop)
    }
}
