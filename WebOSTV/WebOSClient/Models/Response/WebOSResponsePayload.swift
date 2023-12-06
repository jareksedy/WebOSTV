//
//  WebOSResponsePayload.swift
//  WebOSTV
//
//  Created by Ярослав on 06.12.2023.
//

import Foundation

struct WebOSResponsePayload: Codable {
    var pairingType: String?
    var returnValue: Bool?
    var clientKey: String?
    var toastId: String?
    
    enum CodingKeys: String, CodingKey {
        case pairingType
        case returnValue
        case clientKey = "client-key"
        case toastId
    }
}
