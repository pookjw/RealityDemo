//
//  SkyboxMaterialView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/19/25.
//

import SwiftUI
import RealityFoundation

struct SkyboxMaterialView: View {
    @Binding private var material: __SkyboxMaterial
    private let completionHandler: (() -> Void)?
    @State private var pop = false
    
    init(
        material: Binding<__SkyboxMaterial>,
        completionHandler: (() -> Void)? = nil
    ) {
        _material = material
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        Text("Nothing to configure")
            .navigationTitle(_typeName(__SkyboxMaterial.self))
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
