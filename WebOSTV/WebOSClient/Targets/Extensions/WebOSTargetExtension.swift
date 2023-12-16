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
        case .volumeUp:
            return "ssap://audio/volumeUp"
        case .volumeDown:
            return "ssap://audio/volumeDown"
        case .getVolume:
            return "ssap://audio/getVolume"
        case .setVolume:
            return "ssap://audio/setVolume"
        case .setMute:
            return "ssap://audio/setMute"
        case .play:
            return "ssap://media.controls/play"
        case .pause:
            return "ssap://media.controls/pause"
        case .stop:
            return "ssap://media.controls/stop"
        case .rewind:
            return "ssap://media.controls/rewind"
        case .fastForward:
            return "ssap://media.controls/fastForward"
        case .getSoundOutput:
            return "ssap://audio/getSoundOutput"
        case .changeSoundOutput:
            return "ssap://audio/changeSoundOutput"
        case .notify:
            return "ssap://system.notifications/createToast"
        case .screenOff:
            return "ssap://com.webos.service.tvpower/power/turnOffScreen"
        case .screenOn:
            return "ssap://com.webos.service.tvpower/power/turnOnScreen"
        case .systemInfo:
            return "ssap://com.webos.service.update/getCurrentSWInformation"
        case .turnOff:
            return "ssap://system/turnOff"
        case .listApps:
            return "ssap://com.webos.applicationManager/listApps"
        case .getForegroundApp:
            return "ssap://com.webos.applicationManager/getForegroundAppInfo"
        case .launchApp:
            return "ssap://system.launcher/launch"
        case .closeApp:
            return "ssap://system.launcher/close"
        case .insertText:
            return "ssap://com.webos.service.ime/insertText"
        case .sendEnterKey:
            return "ssap://com.webos.service.ime/sendEnterKey"
        case .deleteCharacters:
            return "ssap://com.webos.service.ime/deleteCharacters"
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
        case .getVolume(let subscribe):
            return .init(type: subscribe ? .subscribe : .request, id: uuid, uri: uri)
        case .setVolume(let volume):
            let payload = WebOSRequestPayload(volume: volume)
            return .init(type: .request, id: uuid, uri: uri, payload: payload)
        case .setMute(let mute):
            let payload = WebOSRequestPayload(mute: mute)
            return .init(type: .request, id: uuid, uri: uri, payload: payload)
        case .getSoundOutput(let subscribe):
            return .init(type: subscribe ? .subscribe : .request, id: uuid, uri: uri)
        case .changeSoundOutput(let soundOutput):
            let payload = WebOSRequestPayload(output: soundOutput.rawValue)
            return .init(type: .request, id: uuid, uri: uri, payload: payload)
        case .notify(let message, let iconData, let iconExtension):
            let payload = WebOSRequestPayload(
                message: message,
                iconData: iconData,
                iconExtension: iconExtension
            )
            return .init(type: .request, id: uuid, uri: uri, payload: payload)
        case .screenOn, .screenOff:
            let payload = WebOSRequestPayload(standbyMode: "active")
            return .init(type: .request, id: uuid, uri: uri, payload: payload)
        case .getForegroundApp(let subscribe):
            return .init(type: subscribe ? .subscribe : .request, id: uuid, uri: uri)
        case .launchApp(let appId, let contentId, let params):
            let payload = WebOSRequestPayload(id: appId, contentId: contentId, params: params)
            return .init(type: .request, id: uuid, uri: uri, payload: payload)
        case .closeApp(let appId, let sessionId):
            let payload = WebOSRequestPayload(id: appId, sessionId: sessionId)
            return .init(type: .request, id: uuid, uri: uri, payload: payload)
        case .insertText(let text, let replace):
            let payload = WebOSRequestPayload(text: text, replace: replace)
            return .init(type: .request, id: uuid, uri: uri, payload: payload)
        case .deleteCharacters(let count):
            let payload = WebOSRequestPayload(count: count)
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
