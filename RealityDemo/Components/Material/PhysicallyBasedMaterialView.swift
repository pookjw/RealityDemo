//
//  PhysicallyBasedMaterialView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/19/25.
//

import SwiftUI
import RealityFoundation

struct PhysicallyBasedMaterialView: View {
    @Binding private var material: PhysicallyBasedMaterial
    private let completionHandler: (() -> Void)?
    @State private var pop = false
    
    init(
        material: Binding<PhysicallyBasedMaterial>,
        completionHandler: (() -> Void)? = nil
    ) {
        _material = material
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        Form {
            NavigationLink {
                UIKitColorPicker(
                    selectedColor: Binding(
                        get: {
                            material.baseColor.tint
                        },
                        set: { newValue in
                            material.baseColor.tint = newValue
                        }
                    )
                )
            } label: {
                HStack {
                    Text("baseColor.tint")
                    Spacer()
                    Circle()
                        .fill(Color(uiColor: material.baseColor.tint))
                        .frame(width: 25.0, height: 25.0)
                }
            }
        }
            .navigationTitle(_typeName(PhysicallyBasedMaterial.self))
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
