//
//  WebOSTarget.swift
//  WebOSTV
//
//  Created by Ярослав on 06.12.2023.
//

import Foundation

enum WebOSTarget {
    case connect(clientKey: String?)
    case createToast(message: String, iconData: Data? = nil, iconExtension: String? = nil)
    case volumeUp
    case volumeDown
    case getVolume
    case setVolume(Int)
    case setMute(Bool)
    case play
    case pause
    case stop
    case rewind
    case fastForward
}
