//
//  WebOSTarget.swift
//  WebOSTV
//
//  Created by Ярослав on 06.12.2023.
//

import Foundation

enum WebOSTarget {
    // Connection
    case connect(clientKey: String?)
    // Audio
    case volumeUp
    case volumeDown
    case getVolume(subscribe: Bool = false)
    case setVolume(Int)
    case setMute(Bool)
    case play
    case pause
    case stop
    case rewind
    case fastForward
    case getSoundOutput(subscribe: Bool = false)
    case changeSoundOutput(SoundOutputType)
    // System
    case notify(message: String, iconData: Data? = nil, iconExtension: String? = nil)
    case screenOff
    case screenOn
    case systemInfo
    case turnOff
    // Apps
    case listApps
    case getForegroundApp(subscribe: Bool = false)
    case launchApp(appId: String, contentId: String? = nil, params: String? = nil)
    case closeApp(appId: String, sessionId: String? = nil)
}
