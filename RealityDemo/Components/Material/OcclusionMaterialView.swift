//
//  OcclusionMaterialView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/19/25.
//

import SwiftUI
import RealityFoundation

struct OcclusionMaterialView: View {
    @State private var occlusionMaterial: OcclusionMaterial
    private let didChangeHandler: ((OcclusionMaterial) -> Void)?
    private let completionHandler: ((OcclusionMaterial) -> Void)?
    @State private var pop = false
    
    init(
        occlusionMaterial: OcclusionMaterial = OcclusionMaterial(),
        didChangeHandler: ((OcclusionMaterial) -> Void)? = nil,
        completionHandler: ((OcclusionMaterial) -> Void)? = nil
    ) {
        _occlusionMaterial = State<OcclusionMaterial>(initialValue: occlusionMaterial)
        self.didChangeHandler = didChangeHandler
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        Form {
            Section {
                Toggle("Reads Depth", isOn: $occlusionMaterial.readsDepth)
            }
            
            Section("Face Culling") {
                ForEach(SimpleMaterial.FaceCulling.allCases) { faceCulling in
                    Button {
                        occlusionMaterial.faceCulling = faceCulling
                    } label: {
                        Label {
                            Text(faceCulling.title)
                        } icon: {
                            if occlusionMaterial.faceCulling == faceCulling {
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
        .toolbar {
            if let completionHandler {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", systemImage: "checkmark") {
                        completionHandler(occlusionMaterial)
                        pop = true
                    }
                }
            }
        }
        .pop(pop)
    }
}
