//
//  MaterialParameterTypes_TriangleFillMode+.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/19/25.
//

import RealityFoundation

extension MaterialParameterTypes.TriangleFillMode: @retroactive CaseIterable, @retroactive Identifiable {
    public static nonisolated(unsafe) let allCases: [MaterialParameterTypes.TriangleFillMode] = [.fill, .lines]
    
    public var id: Int {
        hashValue
    }
    
    var title: String {
        switch self {
        case .fill:
            return "Fill"
        case .lines:
            return "Lines"
        @unknown default:
            fatalError()
        }
    }
}
