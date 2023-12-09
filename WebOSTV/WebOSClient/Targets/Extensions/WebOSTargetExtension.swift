//
//  WebOSTargetExtension.swift
//  WebOSTV
//
//  Created by Ярослав on 09.12.2023.
//

import Foundation

extension WebOSTarget: WebOSTargetProtocol {
    var uuid: String {
        return UUID().uuidString.lowercased()
    }
    
    var uri: String? {
        switch self {
        case .createToast:
            return "ssap://system.notifications/createToast"
        case .volumeUp:
            return "ssap://audio/volumeUp"
        case .volumeDown:
            return "ssap://audio/volumeDown"
        case .getVolume:
            return "ssap://audio/getVolume"
        case .setVolume:
            return "ssap://audio/setVolume"
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
                pairingType: .prompt,
                clientKey: clientKey
            )
            return .init(type: .register, id: uuid, payload: payload)
        case .createToast(let message, let iconData, let iconExtension):
            let payload = WebOSRequestPayload(
                message: message,
                iconData: iconData,
                iconExtension: iconExtension
            )
            return .init(type: .request, id: uuid, uri: uri, payload: payload)
        case .setVolume(let volume):
            let payload = WebOSRequestPayload(volume: volume)
            return .init(type: .request, id: uuid, uri: uri, payload: payload)
        default:
            return .init(type: .request, id: uuid, uri: uri)
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
