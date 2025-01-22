//
//  UISceneDelegate+ForwadingDelegate.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/22/25.
//

import UIKit
import ObjectiveC

extension UISceneDelegate {
    var forwardingDelegate: (any UISceneDelegate)? {
        let _TtC7SwiftUI16AppSceneDelegate: AnyClass =  objc_lookUpClass("_TtC7SwiftUI16AppSceneDelegate")!
        
        guard Self.self == _TtC7SwiftUI16AppSceneDelegate,
              let sceneDelegateBox = unsafeBitCast(Mirror(reflecting: self).descendant("sceneDelegateBox")!, to: AnyObject?.self)
        else {
            return nil
        }
        
        let typedDelegate = Mirror(reflecting: sceneDelegateBox).descendant("typedDelegate")! as! (any UIWindowSceneDelegate)
        return typedDelegate
    }
}
