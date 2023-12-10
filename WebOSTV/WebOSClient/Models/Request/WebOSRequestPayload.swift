//
//  WebOSRequestPayload.swift
//  WebOSTV
//
//  Created by Ярослав on 06.12.2023.
//

import Foundation

struct WebOSRequestPayload: Codable {
    var forcePairing: Bool?
    var manifest: WebOSRequestManifest?
    var pairingType: String?
    var clientKey: String?
    var message: String?
    var iconData: Data?
    var iconExtension: String?
    var volume: Int?
    var mute: Bool?
    
    enum CodingKeys: String, CodingKey {
        case clientKey = "client-key"
        case forcePairing
        case manifest
        case pairingType
        case message
        case iconData
        case iconExtension
        case volume
        case mute
    }
}
