//
//  AddMaterialView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/19/25.
//

import SwiftUI
import RealityFoundation

struct AddMaterialView: View {
    @Binding private var component: ModelComponent
    @State private var pop = false
    
    init(component: Binding<ModelComponent>) {
        _component = component
    }
    
    var body: some View {
        Form {
            NavigationLink("SimpleMaterial") {
                SimpleMaterialView(
                    completionHandler: { result in
                        component.materials.append(result)
                        pop = true
                    }
                )
            }
            
            NavigationLink("OcclusionMaterial") {
                OcclusionMaterialView(
                    completionHandler: { result in
                        component.materials.append(result)
                        pop = true
                    }
                )
            }
        }
        .pop(pop)
        .onDisappear {
            pop = false
        }
    }
}
