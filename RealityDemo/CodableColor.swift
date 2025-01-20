//
//  CodableColor.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/20/25.
//

import SwiftUICore

@dynamicMemberLookup
struct CodableColor {
    var colorSpace: CGColorSpace?
    var components: [CGFloat]
}

extension CodableColor {
    init?(_ swiftUI: Color) {
        guard let cgColor = swiftUI.cgColor else {
            return nil
        }
        
        self.init(cgColor)
    }
    
    init?(_ uiKit: UIColor) {
        self.init(uiKit.cgColor)
    }
    
    init?(_ coreGraphics: CGColor) {
        guard let colorSpace = coreGraphics.colorSpace else {
            return nil
        }
        
        self.colorSpace = colorSpace
        components = coreGraphics.components ?? []
    }
}

extension CodableColor {
    var swiftUI: Color? {
        get {
            guard let cgColor = coreGraphics else { return nil }
            return Color(cgColor: cgColor)
        }
        set {
            coreGraphics = newValue?.cgColor
        }
    }
    
    var uiKit: UIColor? {
        get {
            guard let cgColor = coreGraphics else { return nil }
            return UIColor(cgColor: cgColor)
        }
        set {
            coreGraphics = newValue?.cgColor
        }
    }
    
    var coreGraphics: CGColor? {
        get {
            guard let colorSpace else { return nil }
            
            return components.withUnsafeBufferPointer { pointer in
                CGColor(colorSpace: colorSpace, components: pointer.baseAddress!)!
            }
        }
        set {
            colorSpace = newValue?.colorSpace
            components = newValue?.components ?? []
        }
    }
}

extension CodableColor: Codable {
    private enum CodingKeys: CodingKey {
        case colorSpace, components
    }
    
    private enum DecodingError: Error {
        case invalidColor
    }
    
    private enum EncodingError: Error {
        case invalidColorspace
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let colorSpaceString = try container.decodeIfPresent(String.self, forKey: .colorSpace) {
            guard let colorSpace = CGColorSpace(name: colorSpaceString as CFString) else {
                throw DecodingError.invalidColor
            }
            
            self.colorSpace = colorSpace
        } else {
            colorSpace = nil
        }
        
        components = try container.decode([CGFloat].self, forKey: .components)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(colorSpace?.name as String?, forKey: .colorSpace)
        try container.encode(components, forKey: .components)
    }
}

extension CodableColor: Hashable {}

extension CodableColor {
    subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<UIColor?, Value>) -> Value {
        get {
            return uiKit[keyPath: keyPath]
        }
        set {
            uiKit[keyPath: keyPath] = newValue
        }
    }
    
    subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Color?, Value>) -> Value {
        get {
            return swiftUI[keyPath: keyPath]
        }
        set {
            swiftUI[keyPath: keyPath] = newValue
        }
    }
    
    subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<CGColor?, Value>) -> Value {
        get {
            return coreGraphics[keyPath: keyPath]
        }
        set {
            coreGraphics[keyPath: keyPath] = newValue
        }
    }
}
