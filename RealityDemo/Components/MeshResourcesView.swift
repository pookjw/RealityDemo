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
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", systemImage: "checkmark") {
                    meshResourceHandler(descriptor.meshResource)
//                    realityService.stack.removeLast()
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
        }
    }
}

extension PrimitiveMesh {
    @_typeEraser(AnyDescriptor) protocol Descriptor: Equatable {
        var meshResource: MeshResource { get }
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
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.XY_Plane, Float> {
                var plane = self as! PrimitiveMesh.XY_Plane
                plane[keyPath: castedPath] = newValue
                self = plane as! Self
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.XZ_Plane, Float> {
                var plane = self as! PrimitiveMesh.XZ_Plane
                plane[keyPath: castedPath] = newValue
                self = plane as! Self
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Sphere, Float> {
                var plane = self as! PrimitiveMesh.Sphere
                plane[keyPath: castedPath] = newValue
                self = plane as! Self
            } else if let castedPath = path as? WritableKeyPath<PrimitiveMesh.Cone, Float> {
                var plane = self as! PrimitiveMesh.Cone
                plane[keyPath: castedPath] = newValue
                self = plane as! Self
            } else {
                fatalError()
            }
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
