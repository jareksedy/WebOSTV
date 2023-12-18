//
//  WebOSKeyTargetExtension.swift
//  WebOSTV
//
//  Created by Ярослав on 18.12.2023.
//

import Foundation

extension WebOSKeyTarget: WebOSKeyTargetProtocol {
    var name: String? {
        switch self {
        case .home:
            return "HOME"
        default:
            return nil
        }
    }
    
    var type: WebOSKeyType {
        switch self {
        case .move:
            return .move
        case .click:
            return .click
        case .scroll:
            return .scroll
        default:
            return .button
        }
    }
    
    var request: Data? {
        switch self {
        case .move(let dx, let dy, let down):
            return "type:\(type)\ndx:\(dx)\ndy:\(dy)\ndown:\(down)\n\n".data(using: .utf8)
        case .scroll(let dx, let dy):
            return "type:\(type)\ndx:\(dx)\ndy:\(dy)\n\n".data(using: .utf8)
        default:
            if let name {
                return "type:\(type)\nname:\(name)\n\n".data(using: .utf8)
            }
            return "type:\(type)\n\n".data(using: .utf8)
        }
    }
}
