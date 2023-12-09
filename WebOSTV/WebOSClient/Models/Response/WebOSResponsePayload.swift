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
    var callerId: String?
    var volume: Int?
    var soundOutput: String?
    var volumeStatus: WebOSResponseVolumeStatus?
    
    enum CodingKeys: String, CodingKey {
        case pairingType
        case returnValue
        case clientKey = "client-key"
        case toastId
        case callerId
        case volume
        case soundOutput
        case volumeStatus
    }
}
