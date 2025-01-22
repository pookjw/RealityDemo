//
//  UIApplicationDelegate+forwardingDelegate.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/22/25.
//

import UIKit
import ObjectiveC

extension UIApplicationDelegate {
    var forwardingDelegate: (any UIApplicationDelegate)? {
        let _TtC7SwiftUI11AppDelegate: AnyClass = objc_lookUpClass("_TtC7SwiftUI11AppDelegate")!
        
        guard Self.self == _TtC7SwiftUI11AppDelegate,
              let fallbackDelegate = Mirror(reflecting: self).descendant("fallbackDelegate")! as? (any UIApplicationDelegate)?
        else {
            return nil
        }
        
        return fallbackDelegate
    }
}
