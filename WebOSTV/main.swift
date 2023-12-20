//
//  main.swift
//  WebOSTV
//
//  Created by Ярослав on 29.11.2023.
//

import Foundation

class Application {
    var webOSClient: WebOSClientProtocol
    var listAppsId: String?
    
    init(webOSClient: WebOSClientProtocol) {
        self.webOSClient = webOSClient
    }
    
    func run() {
        webOSClient.delegate = self
        webOSClient.connect()
        let clientKey = UserDefaults.standard.value(forKey: "clientKey") as? String
        webOSClient.send(.register(clientKey: clientKey))
        
        while let input = readLine(), input != "exit" {
            switch input {
            case "_clearClientKey":
                UserDefaults.standard.setValue(nil, forKey: "clientKey")
                print("clientKey set to nil!")
            case "_connect":
                webOSClient.connect()
                let clientKey = UserDefaults.standard.value(forKey: "clientKey") as? String
                webOSClient.send(.register(clientKey: clientKey))
            case "_disconnect":
                webOSClient.disconnect(with: .goingAway)
            case "volumeUp":
                webOSClient.send(.volumeUp)
            case "volumeDown":
                webOSClient.send(.volumeDown)
            case "getVolume":
                webOSClient.send(.getVolume())
            case "getVolume subscribe":
                webOSClient.send(.getVolume(subscribe: true), id: "volumeSubscription")
            case "getVolume unsubscribe":
                webOSClient.send(.getVolume(subscribe: false), id: "volumeSubscription")
            case "setVolume":
                print("Volume: ", terminator: "")
                if let volume = Int(readLine()!) {
                    webOSClient.send(.setVolume(volume))
                }
            case "setMute":
                print("Mute: ", terminator: "")
                if let mute = Bool(readLine()!) {
                    webOSClient.send(.setMute(mute))
                }
            case "play":
                webOSClient.send(.play)
            case "pause":
                webOSClient.send(.pause)
            case "stop":
                webOSClient.send(.stop)
            case "rewind":
                webOSClient.send(.rewind)
            case "fastForward":
                webOSClient.send(.fastForward)
            case "getSoundOutput":
                webOSClient.send(.getSoundOutput())
            case "getSoundOutput subscribe":
                webOSClient.send(.getSoundOutput(subscribe: true))
            case "changeSoundOutput":
                print("Output: ", terminator: "")
                if let output = WebOSSoundOutputType(rawValue: String(readLine()!)) {
                    webOSClient.send(.changeSoundOutput(output))
                }
            case "screenOff":
                webOSClient.send(.screenOff)
            case "screenOn":
                webOSClient.send(.screenOn)
            case "sysInfo":
                webOSClient.send(.systemInfo)
            case "turnOff":
                webOSClient.send(.turnOff)
            case "listApps":
                listAppsId = webOSClient.send(.listApps)
            case "getForegroundApp":
                webOSClient.send(.getForegroundApp())
            case "getForegroundApp subscribe":
                webOSClient.send(.getForegroundApp(subscribe: true), id: "appSubscription")
            case "getForegroundApp unsubscribe":
                webOSClient.send(.getForegroundApp(subscribe: false), id: "appSubscription")
            case "launchApp":
                print("AppId: ", terminator: "")
                if let appId = readLine() {
                    webOSClient.send(.launchApp(appId: appId))
                }
            case "closeApp":
                print("AppId: ", terminator: "")
                if let appId = readLine() {
                    webOSClient.send(.closeApp(appId: appId))
                }
            case "insertText":
                print("Text: ", terminator: "")
                if let text = readLine() {
                    webOSClient.send(.insertText(text: text))
                }
            case "enter":
                webOSClient.send(.sendEnterKey)
            case "delete":
                webOSClient.send(.deleteCharacters())
            case "getPointerInputSocket":
                webOSClient.send(.getPointerInputSocket)
            case "send":
                print("Request: ", terminator: "")
                if let request = readLine() {
                    webOSClient.send(request)
                }
            case "key_click":
                webOSClient.sendKey(.click)
            case "key_move":
                webOSClient.sendKey(.move(dx: -550, dy: -200))
            case "key_scroll":
                webOSClient.sendKey(.scroll(dx: 0, dy: 50))
            case "key_home":
                webOSClient.sendKey(.home)
            case "key_back":
                webOSClient.sendKey(.back)
            case "key_pause":
                webOSClient.sendKey(.pause)
            case "key_play":
                webOSClient.sendKey(.play)
            case "key_volDown":
                webOSClient.sendKey(.volumeDown)
            case "key_volUp":
                webOSClient.sendKey(.volumeUp)
            case "key_cc":
                webOSClient.sendKey(.cc)
            case "key_left":
                webOSClient.sendKey(.left)
            case "key_right":
                webOSClient.sendKey(.right)
            case "key_up":
                webOSClient.sendKey(.up)
            case "key_down":
                webOSClient.sendKey(.down)
            case "key_ok":
                webOSClient.sendKey(.enter)
            case "key_green":
                webOSClient.sendKey(.green)
            case "key_red":
                webOSClient.sendKey(.red)
            case "key_blue":
                webOSClient.sendKey(.blue)
            case "key_yellow":
                webOSClient.sendKey(.yellow)
            case "key_info":
                webOSClient.sendKey(.info)
            case "key_menu":
                webOSClient.sendKey(.menu)
            case "key_volumeUp":
                webOSClient.sendKey(.volumeUp)
            case "key_volumeDown":
                webOSClient.sendKey(.volumeDown)
            case "key_mute":
                webOSClient.sendKey(.mute)
            default:
                webOSClient.send(.notify(message: input))
            }
            
        }
        webOSClient.disconnect(with: .goingAway)
    }
}

extension Application: WebOSClientDelegate {
    func didConnect(with task: URLSessionWebSocketTask) {
        print("Connected. Task: \(task.description)")
    }
    
    func didDisconnect(with error: Error?) {
        if let error {
            print("Disconnected with error: \(error.localizedDescription).")
        } else {
            print("Disconnected. No errors.")
        }
    }
    
    func didPrompt() {
        print("Please accept registration prompt on the TV.")
    }
    
    func didRegister(with clientKey: String) {
        print("Registered with client key: \(clientKey)")
        UserDefaults.standard.setValue(clientKey, forKey: "clientKey")
    }
    
    func didReceive(_ result: Result<WebOSResponse, Error>) {
        switch result {
        case .success(let response):
            if response.id == "volumeSubscription" {
                print("vol: \(response.payload?.volumeStatus?.volume ?? -1)")
                return
            }
            if response.id == "appSubscription" {
                print("app: \(response.payload?.appId ?? "nan")")
                return
            }
            print(response)
        case .failure(let error):
            print("Error received: \(error)")
        }
    }
}

let url = URL(string: "wss://192.168.8.10:3001")
let webOSClient = WebOSClient(url: url)
let application = Application(webOSClient: webOSClient)
application.run()
