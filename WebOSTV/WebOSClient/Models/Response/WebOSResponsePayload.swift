//
//  WebOSResponsePayload.swift
//  WebOSTV
//
//  Created by Ярослав on 06.12.2023.
//

import Foundation

struct WebOSResponsePayload: Codable {
    let pairingType: String?
    let returnValue: Bool?
    let clientKey: String?
    let toastId: String?
    let callerId: String?
    let volume: Int?
    let soundOutput: String?
    let volumeStatus: WebOSResponseVolumeStatus?
    let muteStatus: Bool?
    let method: String?
    
    enum CodingKeys: String, CodingKey {
        case pairingType
        case returnValue
        case clientKey = "client-key"
        case toastId
        case callerId
        case volume
        case soundOutput
        case volumeStatus
        case muteStatus
        case method
    }
}
