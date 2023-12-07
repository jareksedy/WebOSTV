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
    var json: String? { get }
}

enum WebOSTarget {
    case connect(clientKey: String?)
    case createToast(message: String, iconData: Data? = nil, iconExtension: String? = nil)
}

extension WebOSTarget: WebOSTargetProtocol {
    var uuid: String {
        return UUID().uuidString.lowercased()
    }
    
    var uri: String? {
        switch self {
        case .createToast:
            return "ssap://system.notifications/createToast"
        default:
            return nil
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
            return .init(type: "register", id: uuid, payload: payload)
        case .createToast(let message, let iconData, let iconExtension):
            let payload = WebOSRequestPayload(
                message: message,
                iconData: iconData,
                iconExtension: iconExtension
            )
            return .init(type: "request", id: uuid, uri: uri, payload: payload)
        }
    }
    
    var json: String? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(request)
            if let jsonString = String(data: jsonData, encoding: .utf8) { return jsonString }
        } catch {
            print("Error encoding JSON: \(error)")
        }
        return nil
    }
}
