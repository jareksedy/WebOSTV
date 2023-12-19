//
//  WebOSKeyTargetProtocol.swift
//  WebOSTV
//
//  Created by Ярослав on 18.12.2023.
//

import Foundation

protocol WebOSKeyTargetProtocol {
    var name: String { get }
    var request: Data? { get }
}
