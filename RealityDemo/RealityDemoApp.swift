//
//  RealityDemoApp.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/14/25.
//

import SwiftUI

@main
struct RealityDemoApp: App {
    @State private var realityService = RealityService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(realityService)
        }
        .windowStyle(.volumetric)
    }
}
