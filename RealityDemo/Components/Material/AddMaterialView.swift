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
            NavigationLink(_mangledTypeName(SimpleMaterial.self)!) {
                MaterialEntryView(material: SimpleMaterial()) { binding in
                    SimpleMaterialView(material: binding) {
                        component.materials.append(binding.wrappedValue)
                        pop = true
                    }
                }
            }
            
            NavigationLink(_mangledTypeName(OcclusionMaterial.self)!) {
                MaterialEntryView(material: OcclusionMaterial()) { binding in
                    OcclusionMaterialView(material: binding) {
                        component.materials.append(binding.wrappedValue)
                        pop = true
                    }
                }
            }
            
            NavigationLink(_mangledTypeName(__SkyboxMaterial.self)!) {
                MaterialEntryView(material: __SkyboxMaterial()) { binding in
                    SkyboxMaterialView(material: binding) {
                        component.materials.append(binding.wrappedValue)
                        pop = true
                    }
                }
            }
            
            NavigationLink(_mangledTypeName(UnlitMaterial.self)!) {
                MaterialEntryView(material: UnlitMaterial()) { binding in
                    UnlitMaterialView(material: binding) {
                        component.materials.append(binding.wrappedValue)
                        pop = true
                    }
                }
            }
            
            NavigationLink(_mangledTypeName(PhysicallyBasedMaterial.self)!) {
                MaterialEntryView(material: PhysicallyBasedMaterial()) { binding in
                    PhysicallyBasedMaterialView(material: binding) {
                        component.materials.append(binding.wrappedValue)
                        pop = true
                    }
                }
            }
        }
        .pop(pop)
        .onDisappear {
            pop = false
        }
        
    }
}

fileprivate struct MaterialEntryView<T: RealityFoundation.Material, C: View>: View {
    @State private var material: T
    private let contentBuilder: (Binding<T>) -> C
    
    init(
        material: T,
        @ViewBuilder contentBuilder: @escaping (Binding<T>) -> C
    ) {
        self.material = material
        self.contentBuilder = contentBuilder
    }
    
    var body: some View {
        contentBuilder($material)
    }
}
