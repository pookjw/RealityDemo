//
//  AppDelegate.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/20/25.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = connectingSceneSession.configuration.copy() as! UISceneConfiguration
        
        let sceneIDs = options
            .userActivities
            .compactMap { $0.userInfo?["com.apple.SwiftUI.sceneID"] as? String }
        
        if sceneIDs.first == "ColorPickerWindow" {
            configuration.delegateClass = UIKitColorPickerSceneDelegate.self
        } else {
            // https://x.com/_silgen_name/status/1881293088720838775
            configuration.delegateClass = nil
        }
        
        return configuration
    }
}
