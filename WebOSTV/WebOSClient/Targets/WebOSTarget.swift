//
//  WebOSTarget.swift
//  WebOSTV
//
//  Created by Ярослав on 06.12.2023.
//

import Foundation

enum WebOSTarget {
    // Connection
    case register(clientKey: String?)
    // Audio
    case volumeUp
    case volumeDown
    case getVolume(subscribe: Bool? = nil)
    case setVolume(Int)
    case setMute(Bool)
    case play
    case pause
    case stop
    case rewind
    case fastForward
    case getSoundOutput(subscribe: Bool? = nil)
    case changeSoundOutput(WebOSSoundOutputType)
    // System
    case notify(message: String, iconData: Data? = nil, iconExtension: String? = nil)
    case screenOff
    case screenOn
    case systemInfo
    case turnOff
    // Apps
    case listApps
    case getForegroundApp(subscribe: Bool? = nil)
    case launchApp(appId: String, contentId: String? = nil, params: String? = nil)
    case closeApp(appId: String, sessionId: String? = nil)
    // Input
    case insertText(text: String, replace: Int = 0)
    case sendEnterKey
    case deleteCharacters(count: Int = 1)
    case getPointerInputSocket
}
