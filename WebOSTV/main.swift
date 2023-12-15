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
        
        let clientKey = UserDefaults.standard.value(forKey: "clientKey") as? String
        webOSClient.send(.connect(clientKey: clientKey))
        
        while let input = readLine(), input != "exit" {
            switch input {
            case "volumeUp":
                webOSClient.send(.volumeUp)
            case "volumeDown":
                webOSClient.send(.volumeDown)
            case "getVolume":
                webOSClient.send(.getVolume())
            case "getVolume subscribe":
                webOSClient.send(.getVolume(subscribe: true))
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
                if let output = SoundOutputType(rawValue: String(readLine()!)) {
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
                webOSClient.send(.getForegroundApp(subscribe: true))
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
            default:
                webOSClient.send(.notify(message: input))
            }
            
        }
        
        webOSClient.disconnect(with: .goingAway)
    }
}

extension Application: WebOSClientDelegate {
    func didPrompt() {
        print("Please accept connection on the TV.")
    }
    
    func didConnect(with clientKey: String) {
        print("Registered with client key: \(clientKey)")
        UserDefaults.standard.setValue(clientKey, forKey: "clientKey")
    }
    
    func didReceive(_ result: Result<WebOSResponse, Error>) {
        switch result {
        case .success(let response):
            print(response)
        case .failure(let error):
            print("Error received: \(error)")
        }
    }
}


//UserDefaults.standard.setValue(nil, forKey: "clientKey")

let url = URL(string: "wss://192.168.8.10:3001")
let webOSClient = WebOSClient(url: url)
let application = Application(webOSClient: webOSClient)
application.run()
