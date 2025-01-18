//
//  MeshResourcesView.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/17/25.
//

import SwiftUI
import RealityFoundation

struct MeshResourcesView: View {
    @Environment(RealityService.self) private var realityService
    private let meshResourceHandler: (MeshResource) -> Void
    @State private var selectedPrimitiveMesh = PrimitiveMesh.xy_plane
    @State private var descriptor = PrimitiveMesh.AnyDescriptor(erasing: PrimitiveMesh.xy_plane.defaultDescriptor)
    @State private var pop = false
    @State private var popFontPicker = false
    
    init(meshResourceHandler: @escaping (MeshResource) -> Void) {
        self.meshResourceHandler = meshResourceHandler
    }
    
    init(meshResourceHandlerPtr: UnsafeRawPointer) {
        self.meshResourceHandler = unsafeBitCast(meshResourceHandlerPtr, to: ((MeshResource) -> Void).self)
    }
    
    var body: some View {
        Form {
            Section {
                ForEach(PrimitiveMesh.allCases) { primitiveMesh in
                    Button {
                        selectedPrimitiveMesh = primitiveMesh
                        descriptor = PrimitiveMesh.AnyDescriptor(erasing: primitiveMesh.defaultDescriptor)
                    } label: {
                        Label {
                            Text(primitiveMesh.rawValue)
                        } icon: {
                            if selectedPrimitiveMesh == primitiveMesh {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            ForEach(descriptor.keyPaths) { keyPath in
                switch keyPath.dataType {
                case .float(let range):
                    HStack {
                        Text(keyPath.title)
                        Slider(value: $descriptor[_keyPath: keyPath.keyPath], in: range)
                    }
                case .string:
                    HStack {
                        Text(keyPath.title)
                        TextField(text: $descriptor[_keyPath: keyPath.keyPath]) {
                            
                        }
                    }
                case .font:
                    NavigationLink("Font") {
                        FontPicker(
                            configuration: {
                                let configuration = UIFontPickerViewController.Configuration()
                                configuration.displayUsingSystemFont = true
                                configuration.includeFaces = true
                                return configuration
                            }(),
                            didCancelHandler: {
                                popFontPicker = true
                            },
                            didPickFontHandler: { fontDescriptor in
                                popFontPicker = true
                                
                                if let fontDescriptor {
                                    var text = descriptor.unwrapValue as! PrimitiveMesh.Text
                                    text.font = UIFont(descriptor: fontDescriptor, size: text.fontSize)
                                    descriptor = PrimitiveMesh.AnyDescriptor(erasing: text)
                                }
                            }
                        )
                        .pop(popFontPicker)
                    }
                case .attributedString:
                    NavigationLink("Text Editor") {
                        MyTextView(attributedText: $descriptor[_keyPath: keyPath.keyPath])
                    }
                }
            }
        }
        .pop(pop)
        .onAppear {
            pop = false
            popFontPicker = false
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", systemImage: "checkmark") {
                    meshResourceHandler(descriptor.meshResource)
                    pop = true
                }
                .labelStyle(.iconOnly)
            }
        }
    }
}


fileprivate enum PrimitiveMesh: String, CaseIterable, Identifiable {
    case box
    case xy_plane
    case xz_plane
    case sphere
    case cone
    case cylinder
    case text
    case extrudingText
    
    var id: String { rawValue }
    
    var defaultDescriptor: any Descriptor {
        // MARK: 추가될 때
        switch self {
        case .box:
            return Box(
                size: SIMD3<Float>(x: 0.1, y: 0.1, z: 0.1),
                majorCornerRadius: 0.2,
                minorCornerRadius: 0.05
            )
        case .xy_plane:
            return XY_Plane(width: 0.1, height: 0.1, cornerRadius: .zero)
        case .xz_plane:
            return XZ_Plane(width: 0.1, depth: 0.1, cornerRadius: .zero)
        case .sphere:
            return Sphere(radius: 0.1)
        case .cone:
            return Cone(height: 0.1, radius: 0.1)
        case .cylinder:
            return Cylinder(height: 0.1, radius: 0.1)
        case .text:
            return Text(
                string: "Hello",
                extrusionDepth: 0.25,
                font: .systemFont(ofSize: 0.1),
                containerFrame: .zero
            )
        case .extrudingText:
            var attributes = AttributeContainer()
            attributes.uiKit.strokeColor = .red
            attributes.uiKit.strokeWidth = 3.0
            attributes.uiKit.strikethroughStyle = .single
            attributes.uiKit.strikethroughColor = .green
            attributes.uiKit.font = .boldSystemFont(ofSize: 17.0)
            
            return ExtrudingText(
                string: AttributedString("Hello", attributes: attributes),
                containerFrame: .zero
            )
        }
    }
}

extension PrimitiveMesh {
    @_typeEraser(AnyDescriptor) protocol Descriptor: Equatable {
        @MainActor var meshResource: MeshResource { get }
        var keyPaths: [KeyPathDescriptor] { get }
    }
}

extension PrimitiveMesh {
    struct AnyDescriptor: Descriptor {
        let value: (any Descriptor)
        
        init<T: Descriptor>(erasing value: T) {
            self.value = value
        }
        
        var meshResource: MeshResource {
            value.meshResource
        }
        
        var keyPaths: [PrimitiveMesh.KeyPathDescriptor] {
            value.keyPaths
        }
        
        var unwrapValue: (any Descriptor) {
            if let anyDescriptor = value as? AnyDescriptor {
                return anyDescriptor.unwrapValue
            }
            
            return value
        }
        
        // MARK: 추가될 때
        static func == (lhs: PrimitiveMesh.AnyDescriptor, rhs: PrimitiveMesh.AnyDescriptor) -> Bool {
            switch (lhs.unwrapValue, rhs.unwrapValue) {
            case let (lhs, rhs) as (Box, Box):
                return lhs == rhs
            case let (lhs, rhs) as (XY_Plane, XY_Plane):
                return lhs == rhs
            case let (lhs, rhs) as (XZ_Plane, XZ_Plane):
                return lhs == rhs
            case let (lhs, rhs) as (Sphere, Sphere):
                return lhs == rhs
            case let (lhs, rhs) as (Cone, Cone):
                return lhs == rhs
            case let (lhs, rhs) as (Cylinder, Cylinder):
                return lhs == rhs
            case let (lhs, rhs) as (Text, Text):
                return lhs == rhs
            case let (lhs, rhs) as (ExtrudingText, ExtrudingText):
                return lhs == rhs
            default:
                return false
            }
        }
    }
}

extension PrimitiveMesh.Descriptor {
    // MARK: 추가될 때
    subscript(_keyPath path: AnyKeyPath) -> Float {
        get {
            if let anyDescriptor = self as? PrimitiveMesh.AnyDescriptor {
                return anyDescriptor.unwrapValue[_keyPath: path]
            }
            
            if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Box, Float> {
                guard let box = self as? PrimitiveMesh.Box else { return .zero }
                return box[keyPath: castedPath]
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.XY_Plane, Float> {
                guard let plane = self as? PrimitiveMesh.XY_Plane else { return .zero }
                return plane[keyPath: castedPath]
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.XZ_Plane, Float> {
                guard let plane = self as? PrimitiveMesh.XZ_Plane else { return .zero }
                return plane[keyPath: castedPath]
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Sphere, Float> {
                guard let plane = self as? PrimitiveMesh.Sphere else { return .zero }
                return plane[keyPath: castedPath]
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Cone, Float> {
                guard let plane = self as? PrimitiveMesh.Cone else { return .zero }
                return plane[keyPath: castedPath]
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Cylinder, Float> {
                guard let cylinder = self as? PrimitiveMesh.Cylinder else { return .zero }
                return cylinder[keyPath: castedPath]
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Text, Float> {
                guard let text = self as? PrimitiveMesh.Text else { return .zero }
                return text[keyPath: castedPath]
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Text, CGFloat> {
                guard let text = self as? PrimitiveMesh.Text else { return .zero }
                return Float(text[keyPath: castedPath])
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.ExtrudingText, CGFloat> {
                guard let extrudingText = self as? PrimitiveMesh.ExtrudingText else { return .zero }
                return Float(extrudingText[keyPath: castedPath])
            } else {
                fatalError()
            }
        }
        mutating set {
            if let anyDescriptor = self as? PrimitiveMesh.AnyDescriptor {
                var value = anyDescriptor.unwrapValue
                value[_keyPath: path] = newValue
                self = PrimitiveMesh.AnyDescriptor(erasing: value) as! Self
                return
            }
            
            if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Box, Float> {
                var box = self as! PrimitiveMesh.Box
                box[keyPath: castedPath] = newValue
                self = box as! Self
                return
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.XY_Plane, Float> {
                var plane = self as! PrimitiveMesh.XY_Plane
                plane[keyPath: castedPath] = newValue
                self = plane as! Self
                return
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.XZ_Plane, Float> {
                var plane = self as! PrimitiveMesh.XZ_Plane
                plane[keyPath: castedPath] = newValue
                self = plane as! Self
                return
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Sphere, Float> {
                var plane = self as! PrimitiveMesh.Sphere
                plane[keyPath: castedPath] = newValue
                self = plane as! Self
                return
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Cone, Float> {
                var plane = self as! PrimitiveMesh.Cone
                plane[keyPath: castedPath] = newValue
                self = plane as! Self
                return
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Cylinder, Float> {
                var cylinder = self as! PrimitiveMesh.Cylinder
                cylinder[keyPath: castedPath] = newValue
                self = cylinder as! Self
                return
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Text, Float> {
                var text = self as! PrimitiveMesh.Text
                text[keyPath: castedPath] = newValue
                self = text as! Self
                return
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Text, CGFloat> {
                var text = self as! PrimitiveMesh.Text
                text[keyPath: castedPath] = CGFloat(newValue)
                self = text as! Self
                return
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.ExtrudingText, CGFloat> {
                var extrudingText = self as! PrimitiveMesh.ExtrudingText
                extrudingText[keyPath: castedPath] = CGFloat(newValue)
                self = extrudingText as! Self
                return
            }
            
            fatalError()
        }
    }
    
    subscript(_keyPath path: AnyKeyPath) -> String {
        get {
            if let anyDescriptor = self as? PrimitiveMesh.AnyDescriptor {
                return anyDescriptor.unwrapValue[_keyPath: path]
            }
            
            if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Text, String> {
                guard let text = self as? PrimitiveMesh.Text else { return "" }
                return text[keyPath: castedPath]
            }
            
            fatalError()
        }
        set {
            if let anyDescriptor = self as? PrimitiveMesh.AnyDescriptor {
                var value = anyDescriptor.unwrapValue
                value[_keyPath: path] = newValue
                self = PrimitiveMesh.AnyDescriptor(erasing: value) as! Self
                return
            }
            
            if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Text, String> {
                var text = self as! PrimitiveMesh.Text
                text[keyPath: castedPath] = newValue
                self = text as! Self
                return
            }
            
            fatalError()
        }
    }
    
    subscript(_keyPath path: AnyKeyPath) -> AttributedString {
        get {
            if let anyDescriptor = self as? PrimitiveMesh.AnyDescriptor {
                return anyDescriptor.unwrapValue[_keyPath: path]
            }
            
            if let castedPath = path as? WritableKeyPath<PrimitiveMesh.ExtrudingText, AttributedString> {
                guard let extrudingText = self as? PrimitiveMesh.ExtrudingText else { return "" }
                return extrudingText[keyPath: castedPath]
            }
            
            fatalError()
        }
        set {
            if let anyDescriptor = self as? PrimitiveMesh.AnyDescriptor {
                var value = anyDescriptor.unwrapValue
                value[_keyPath: path] = newValue
                self = PrimitiveMesh.AnyDescriptor(erasing: value) as! Self
                return
            }
            
            if let castedPath = path as? WritableKeyPath<PrimitiveMesh.ExtrudingText, AttributedString> {
                var extrudingText = self as! PrimitiveMesh.ExtrudingText
                extrudingText[keyPath: castedPath] = newValue
                self = extrudingText as! Self
                return
            }
            
            fatalError()
        }
    }
}

extension PrimitiveMesh {
    struct KeyPathDescriptor: Hashable, Identifiable {
        let keyPath: AnyKeyPath
        let title: String
        let dataType: DataType
        
        var id: Int {
            hashValue
        }
        
        enum DataType: Hashable {
            case float(ClosedRange<Float>)
            case string
            case font
            case attributedString
        }
    }
}

extension PrimitiveMesh {
    struct Box: Descriptor {
        var size: SIMD3<Float>
        var majorCornerRadius: Float
        var minorCornerRadius: Float
        
        var meshResource: MeshResource {
            .generateBox(size: size, majorCornerRadius: majorCornerRadius, minorCornerRadius: minorCornerRadius)
        }
        
        let keyPaths: [PrimitiveMesh.KeyPathDescriptor] = [
            KeyPathDescriptor(keyPath: \Self.size.x, title: "Width", dataType: .float(0.0...1.0)),
            KeyPathDescriptor(keyPath: \Self.size.y, title: "Height", dataType: .float(0.0...1.0)),
            KeyPathDescriptor(keyPath: \Self.size.z, title: "Depth", dataType: .float(0.0...1.0)),
            KeyPathDescriptor(keyPath: \Self.majorCornerRadius, title: "Major Corner Radius", dataType: .float(0.0...1.0)),
            KeyPathDescriptor(keyPath: \Self.minorCornerRadius, title: "Minor Corner Radius", dataType: .float(0.0...1.0))
        ]
    }
}

extension PrimitiveMesh {
    struct XY_Plane: Descriptor {
        var width: Float
        var height: Float
        var cornerRadius: Float
        
        var meshResource: MeshResource {
            .generatePlane(width: width, height: height, cornerRadius: cornerRadius)
        }
        
        let keyPaths: [PrimitiveMesh.KeyPathDescriptor] = [
            KeyPathDescriptor(keyPath: \Self.width, title: "Width", dataType: .float(0.0...1.0)),
            KeyPathDescriptor(keyPath: \Self.height, title: "Height", dataType: .float(0.0...1.0)),
            KeyPathDescriptor(keyPath: \Self.cornerRadius, title: "Corner Radius", dataType: .float(0.0...1.0))
        ]
    }
}

extension PrimitiveMesh {
    struct XZ_Plane: Descriptor {
        var width: Float
        var depth: Float
        var cornerRadius: Float
        
        var meshResource: MeshResource {
            .generatePlane(width: width, depth: depth, cornerRadius: cornerRadius)
        }
        
        let keyPaths: [PrimitiveMesh.KeyPathDescriptor] = [
            KeyPathDescriptor(keyPath: \Self.width, title: "Width", dataType: .float(0.0...1.0)),
            KeyPathDescriptor(keyPath: \Self.depth, title: "Depth", dataType: .float(0.0...1.0)),
            KeyPathDescriptor(keyPath: \Self.cornerRadius, title: "Corner Radius", dataType: .float(0.0...1.0))
        ]
    }
}

extension PrimitiveMesh {
    struct Sphere: Descriptor {
        var radius: Float
        
        var meshResource: MeshResource {
            .generateSphere(radius: radius)
        }
        
        let keyPaths: [PrimitiveMesh.KeyPathDescriptor] = [
            KeyPathDescriptor(keyPath: \Self.radius, title: "Radius", dataType: .float(0.0...1.0))
        ]
    }
}

extension PrimitiveMesh {
    struct Cone: Descriptor {
        var height: Float
        var radius: Float
        
        var meshResource: MeshResource {
            .generateCone(height: height, radius: radius)
        }
        
        let keyPaths: [PrimitiveMesh.KeyPathDescriptor] = [
            KeyPathDescriptor(keyPath: \Self.height, title: "Height", dataType: .float(0.0...1.0)),
            KeyPathDescriptor(keyPath: \Self.radius, title: "Radius", dataType: .float(0.0...1.0))
            
        ]
    }
}

extension PrimitiveMesh {
    struct Cylinder: Descriptor {
        var height: Float
        var radius: Float
        
        var meshResource: MeshResource {
            .generateCylinder(height: height, radius: radius)
        }
        
        let keyPaths: [PrimitiveMesh.KeyPathDescriptor] = [
            PrimitiveMesh.KeyPathDescriptor(keyPath: \Self.height, title: "Height", dataType: .float(0.0...1.0)),
            PrimitiveMesh.KeyPathDescriptor(keyPath: \Self.height, title: "Radius", dataType: .float(0.0...1.0))
        ]
    }
}

extension PrimitiveMesh {
    struct Text: Descriptor {
        var string: String
        var extrusionDepth: Float
        var font: MeshResource.Font
        var fontSize: CGFloat {
            get {
                font.pointSize
            }
            set {
                font = font.withSize(newValue)
            }
        }
        var containerFrame: CGRect
        
        var meshResource: MeshResource {
            .generateText(
                string,
                extrusionDepth: extrusionDepth,
                font: font,
                containerFrame: containerFrame,
                alignment: .left,
                lineBreakMode: .byTruncatingTail
            )
        }
        
        let keyPaths: [PrimitiveMesh.KeyPathDescriptor] = [
            PrimitiveMesh.KeyPathDescriptor(keyPath: \Self.string, title: "String", dataType: .string),
            PrimitiveMesh.KeyPathDescriptor(keyPath: \Self.extrusionDepth, title: "Extrusion Depth", dataType: .float(0.0...1.0)),
            PrimitiveMesh.KeyPathDescriptor(keyPath: \Self.fontSize, title: "Font Size", dataType: .float(0.1...1.0)),
            PrimitiveMesh.KeyPathDescriptor(keyPath: \Self.containerFrame.size.width, title: "Width", dataType: .float(0.0...300.0)),
            PrimitiveMesh.KeyPathDescriptor(keyPath: \Self.containerFrame.size.height, title: "Height", dataType: .float(0.0...300.0)),
            PrimitiveMesh.KeyPathDescriptor(keyPath: \Self.font, title: "Font", dataType: .font)
        ]
    }
}

extension PrimitiveMesh {
    struct ExtrudingText: Descriptor {
        var string: AttributedString
        var containerFrame: CGRect
        // TODO: ShapeExtrusionOptions
        
        var meshResource: MeshResource {
            var textOptions = MeshResource.GenerateTextOptions()
            
            if containerFrame == .null || containerFrame == .zero || containerFrame.size.width == .zero || containerFrame.height == .zero {
                textOptions.containerFrame = nil
            } else {
                textOptions.containerFrame = containerFrame
            }
            
            return try! MeshResource(
                extruding: string,
                textOptions: textOptions,
                extrusionOptions: MeshResource.ShapeExtrusionOptions()
            )
        }
        
        let keyPaths: [PrimitiveMesh.KeyPathDescriptor] = [
            PrimitiveMesh.KeyPathDescriptor(keyPath: \Self.string, title: "String", dataType: .attributedString),
            PrimitiveMesh.KeyPathDescriptor(keyPath: \Self.containerFrame.origin.x, title: "Container Frame (X)", dataType: .float(0.0...300.0)),
            PrimitiveMesh.KeyPathDescriptor(keyPath: \Self.containerFrame.origin.y, title: "Container Frame (Y)", dataType: .float(0.0...300.0)),
            PrimitiveMesh.KeyPathDescriptor(keyPath: \Self.containerFrame.size.width, title: "Container Frame (Width)", dataType: .float(0.0...300.0)),
            PrimitiveMesh.KeyPathDescriptor(keyPath: \Self.containerFrame.size.height, title: "Container Frame (Height)", dataType: .float(0.0...300.0)),
        ]
    }
}
