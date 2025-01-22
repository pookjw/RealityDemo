//
//  UIKitColorPickerSceneDelegate.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/22/25.
//

import UIKit

final class UIKitColorPickerSceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    private var key: UUID?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let decoder = JSONDecoder()
        
        let keys = connectionOptions
            .userActivities
            .compactMap { $0.userInfo?["com.apple.SwiftUI.sceneValue"] as? Data }
            .compactMap { try! decoder.decode(UUID.self, from: $0) }
        
        key = keys[0]
        assert(UIKitColorPickerBindingMap.shared.bindings[keys[0]] != nil)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        let key = key!
        
        let refCount = UIApplication
            .shared
            .connectedScenes
            .compactMap { $0.delegate?.forwardingDelegate as? UIKitColorPickerSceneDelegate }
            .filter { $0.key == key }
            .count
        
        if refCount == 0 {
            assert(UIKitColorPickerBindingMap.shared.bindings[key] != nil)
            UIKitColorPickerBindingMap.shared.bindings.removeValue(forKey: key)
        }
    }
}
