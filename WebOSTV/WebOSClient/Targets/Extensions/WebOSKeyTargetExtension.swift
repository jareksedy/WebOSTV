//
//  WebOSKeyTargetExtension.swift
//  WebOSTV
//
//  Created by Ярослав on 18.12.2023.
//

import Foundation

extension WebOSKeyTarget: WebOSKeyTargetProtocol {
    var name: String? {
        switch self {
        case .left:
            return "LEFT"
        case .right:
            return "RIGHT"
        case .up:
            return "UP"
        case .down:
            return "DOWN"
        case .home:
            return "HOME"
        case .back:
            return "BACK"
        case .menu:
            return "MENU"
        case .enter:
            return "ENTER"
        case .dash:
            return "DASH"
        case .info:
            return "INFO"
        case .num1:
            return "1"
        case .num2:
            return "2"
        case .num3:
            return "3"
        case .num4:
            return "4"
        case .num5:
            return "5"
        case .num6:
            return "6"
        case .num7:
            return "7"
        case .num8:
            return "8"
        case .num9:
            return "9"
        case .num0:
            return "0"
        case .asterisk:
            return "ASTERISK"
        case .cc:
            return "CC"
        case .exit:
            return "EXIT"
        case .mute:
            return "MUTE"
        case .red:
            return "RED"
        case .green:
            return "GREEN"
        case .yellow:
            return "YELLOW"
        case .blue:
            return "BLUE"
        case .volumeUp:
            return "VOLUMEUP"
        case .volumeDown:
            return "VOLUMEDOWN"
        case .channelUp:
            return "CHANNELUP"
        case .channelDown:
            return "CHANNELDOWN"
        case .play:
            return "PLAY"
        case .pause:
            return "PAUSE"
        case .stop:
            return "STOP"
        case .rewind:
            return "REWIND"
        case .fastForward:
            return "FASTFORWARD"
        default:
            return nil
        }
    }
    
    var type: WebOSKeyType {
        switch self {
        case .move:
            return .move
        case .click:
            return .click
        case .scroll:
            return .scroll
        default:
            return .button
        }
    }
    
    var request: Data? {
        switch self {
        case .move(let dx, let dy, let down):
            return "type:\(type)\ndx:\(dx)\ndy:\(dy)\ndown:\(down)\n\n".data(using: .utf8)
        case .scroll(let dx, let dy):
            return "type:\(type)\ndx:\(dx)\ndy:\(dy)\n\n".data(using: .utf8)
        default:
            if let name {
                return "type:\(type)\nname:\(name)\n\n".data(using: .utf8)
            }
            return "type:\(type)\n\n".data(using: .utf8)
        }
    }
}
