//
//  MaterialParameterTypes_BlendMode+.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/19/25.
//

import RealityFoundation

extension MaterialParameterTypes.BlendMode: @retroactive CaseIterable, @retroactive Identifiable {
    public static let allCases: [MaterialParameterTypes.BlendMode] = [.add, .alpha]
    
    public var id: Int {
        hashValue
    }
    
    var title: String {
        switch self {
        case .add:
            return "Add"
        case .alpha:
            return "Alpha"
        @unknown default:
            fatalError()
        }
    }
}
