//
//  WebOSTarget.swift
//  WebOSTV
//
//  Created by Ярослав on 06.12.2023.
//

import Foundation

protocol WebOSTargetProtocol {
    var uuid: String { get }
    var uri: String? { get }
    var request: WebOSRequest { get }
}

enum WebOSTarget {
    case connect(clientKey: String?)
    case createToast(message: String, iconData: Data?, iconExtension: String?)
}

extension WebOSTarget: WebOSTargetProtocol {
    var uuid: String {
        return UUID().uuidString
    }
    
    var uri: String? {
        switch self {
        case .connect:
            return nil
        case .createToast:
            return "ssap://system.notifications/createToast"
        }
    }
    
    var request: WebOSRequest {
        switch self {
        case .connect(let clientKey):
            let payload = WebOSRequestPayload(
                forcePairing: false,
                manifest: WebOSRequestManifest(),
                pairingType: "PROMPT",
                clientKey: clientKey
            )
            return .init(type: "request", id: uuid, payload: payload)
        case .createToast(let message, let iconData, let iconExtension):
            let payload = WebOSRequestPayload(
                message: message,
                iconData: iconData,
                iconExtension: iconExtension
            )
            return .init(type: "request", id: uuid, uri: uri, payload: payload)
        }
    }
}
