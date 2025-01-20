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
        
        // https://x.com/_silgen_name/status/1881293088720838775
        configuration.delegateClass = nil
        
        return configuration
    }
}
