//
//  MaterialParameterTypes_FaceCulling+.swift
//  RealityDemo
//
//  Created by Jinwoo Kim on 1/19/25.
//

import RealityFoundation

extension MaterialParameterTypes.FaceCulling: @retroactive CaseIterable, @retroactive Identifiable {
    public static nonisolated(unsafe) let allCases: [MaterialParameterTypes.FaceCulling] = [.none, .back, .front]
    
    public var id: Int {
        hashValue
    }
    
    var title: String {
        switch self {
        case .none:
            return "None"
        case .back:
            return "Back"
        case .front:
            return "Front"
        @unknown default:
            fatalError()
        }
    }
}
