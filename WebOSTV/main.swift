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
        webOSClient.send(.connect(clientKey: clientKey))
        while let input = readLine(), input != "exit" {
            webOSClient.send(.createToast(message: input))
        }
        webOSClient.disconnect(with: .goingAway)
    }
}

extension Application: WebOSClientDelegate {
    func didReceive(_ result: Result<WebOSResponse, Error>) {
        switch result {
        case .success(let response):
            if response.payload?.pairingType == "PROMPT" {
                print("Please accept connection on the TV.")
            }
            if let clientKey = response.payload?.clientKey {
                print("Connected with client key: \(clientKey)")
                UserDefaults.standard.setValue(clientKey, forKey: "clientKey")
            }
            print(response)
        case .failure(let error):
            print("Error received: \(error)")
        }
    }
}

let application = Application()
application.run()

