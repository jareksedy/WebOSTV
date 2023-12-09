//
//  main.swift
//  WebOSTV
//
//  Created by Ярослав on 29.11.2023.
//

import Foundation

class Application {
    var webOSClient: WebOSClientProtocol
    
    init(webOSClient: WebOSClientProtocol) {
        self.webOSClient = webOSClient
    }
    
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
