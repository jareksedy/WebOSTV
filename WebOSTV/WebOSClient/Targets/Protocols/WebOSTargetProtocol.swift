//
//  WebOSTargetProtocol.swift
//  WebOSTV
//
//  Created by Ярослав on 09.12.2023.
//

import Foundation

protocol WebOSTargetProtocol {
    var uuid: String { get }
    var uri: String? { get }
    var request: WebOSRequest { get }
    var json: String? { get }
}
