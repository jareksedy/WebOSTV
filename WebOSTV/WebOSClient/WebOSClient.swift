//
//  WebOSClient.swift
//  WebOSTV
//
//  Created by Ярослав on 29.11.2023.
//

import Foundation

class WebOSClient: NSObject, WebOSClientProtocol {
    private var urlSession: URLSession?
    private var webSocketTask: URLSessionWebSocketTask?
    weak var delegate: WebOSClientDelegate?
    
    init(url: URL?, delegate: WebOSClientDelegate? = nil) {
        super.init()
        guard let url else {
            assertionFailure("Invalid device URL. Terminating.")
            return
        }
        self.delegate = delegate
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        listen { [weak self] result in
            self?.delegate?.didReceive(result)
        }
    }
    
    @discardableResult
    func send(_ target: WebOSTarget, id: String) -> String? {
        guard let json = target.request.jsonWithId(id) else {
            return nil
        }
        let message = URLSessionWebSocketTask.Message.string(json)
        webSocketTask?.send(message) { error in
            if let error = error {
                print(error)
            }
        }
        return id
    }
    
    func disconnect(
        with closeCode: URLSessionWebSocketTask.CloseCode = .goingAway
    ) {
        webSocketTask?.cancel(with: closeCode, reason: nil)
    }
    
    deinit {
        disconnect()
    }
}

private extension WebOSClient {
    func listen(
        _ completion: @escaping (Result<WebOSResponse, Error>) -> Void
    ) {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let response):
                self?.handle(response, completion: completion)
                self?.listen(completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func handle(
        _ response: URLSessionWebSocketTask.Message,
        completion: @escaping (Result<WebOSResponse, Error>) -> Void
    ) {
        guard let response = response.decode(),
              let type = response.type,
              let responseType = ResponseType(rawValue: type) else {
            completion(.failure(NSError(domain: "WebOSClient: Unkown response type.", code: 0)))
            return
        }
        switch responseType {
        case .error:
            let errorMessage = response.error ?? "WebOSClient: Unknown error."
            completion(.failure(NSError(domain: errorMessage, code: 0, userInfo: nil)))
        case .registered:
            if let clientKey = response.payload?.clientKey {
                delegate?.didConnect(with: clientKey)
            }
            fallthrough
        default:
            if response.payload?.pairingType == .prompt {
                delegate?.didPrompt()
            }
            completion(.success(response))
        }
    }
}
