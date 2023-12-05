//
//  main.swift
//  WebOSTV
//
//  Created by Ярослав on 29.11.2023.
//

import Foundation

class Application {
    let webOSClient = WebOSClient(url: URL(string: "wss://192.168.8.10:3001"))
    
    func run() {
        webOSClient.delegate = self
        let clientKey = UserDefaults.standard.value(forKey: "clientKey") as? String
        webOSClient.connect(with: clientKey)
        
        while let input = readLine(), input != "exit" {
            self.webOSClient.toast(message: input, iconData: nil, iconExtension: nil)
        }
    }
}

extension Application: WebOSClientDelegate {
    func didConnect(with clientKey: String?, error: Error?) {
        guard let clientKey else {
            print(error ?? "Unknown error.")
            return
        }
        
        print("CONNECTED. CLIENT KEY: \(clientKey)")
        UserDefaults.standard.setValue(clientKey, forKey: "clientKey")
    }
    
    func didReceive(response: Codable?, error: Error?) {
        guard let response else {
            print(error ?? "Unknown error.")
            return
        }
        
        //print(response)
    }
}

let application = Application()
application.run()
