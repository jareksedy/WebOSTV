//
//  WebOSClient.swift
//  WebOSTV
//
//  Created by Ярослав on 29.11.2023.
//

import Foundation

protocol WebOSClientProtocol {
    func connect()
    func connect(with clientKey: String)
    func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode)
}

protocol WebOSClientDelegate: AnyObject {
    func didConnect(with clientKey: String?, error: Error?)
}

class WebOSClient: NSObject, WebOSClientProtocol {
    private var urlSession: URLSession?
    private var webSocketTask: URLSessionWebSocketTask?
    private var id: String = UUID().uuidString
    
    weak var delegate: WebOSClientDelegate?
    
    init(url: URL?) {
        super.init()
        
        guard let url else {
            assertionFailure("Device URL is nil. Terminating...")
            return
        }
        
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
    }
    
    func connect() {
        let request = WebOSRequestResponse(id: id)
        let message = URLSessionWebSocketTask.Message.string(request.toJSONString()!)
        print(request.toJSONString(prettyPrinted: true)!)
        webSocketTask?.send(message) { [weak self] error in
            if let error {
                self?.delegate?.didConnect(with: nil, error: error)
            } else {
                self?.webSocketTask?.receive { result in
                    switch result {
                    case .success(let message):
                        switch message {
                        case .string(let text):
                            print("Received message: \(text)")
                        case .data(let data):
                            print("Received binary data: \(data)")
                        @unknown default:
                            assertionFailure("Received unknown WebSocket message type")
                        }
                    case .failure(let error):
                        print("WebSocket receive error: \(error)")
                    }
                }
            }
        }
    }
    
    func connect(with clientKey: String) {
    }
    
    func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode = .goingAway) {
        webSocketTask?.cancel(with: closeCode, reason: nil)
    }
}

extension WebOSClient: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
