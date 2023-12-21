//
//  WebOSClient.swift
//  WebOSTV
//
//  Created by Ярослав on 29.11.2023.
//

import Foundation

class WebOSClient: NSObject, WebOSClientProtocol {
    private var url: URL?
    private var urlSession: URLSession?
    private var primaryWebSocketTask: URLSessionWebSocketTask?
    private var secondaryWebSocketTask: URLSessionWebSocketTask?
    private var pointerRequestId: String?
    weak var delegate: WebOSClientDelegate?
    
    init(url: URL?, delegate: WebOSClientDelegate? = nil) {
        super.init()
        self.url = url
        self.delegate = delegate
    }
    
    func connect() {
        guard let url else {
            assertionFailure("Invalid device URL. Terminating.")
            return
        }
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        connect(url, task: &primaryWebSocketTask)
    }
    
    @discardableResult
    func send(_ target: WebOSTarget, id: String) -> String? {
        guard let json = target.request.jsonWithId(id) else {
            return nil
        }
        let message = URLSessionWebSocketTask.Message.string(json)
        sendURLSessionWebSocketTaskMessage(message, task: primaryWebSocketTask)
        return id
    }
    
    func send(_ jsonRequest: String) {
        let message = URLSessionWebSocketTask.Message.string(jsonRequest)
        sendURLSessionWebSocketTaskMessage(message, task: primaryWebSocketTask)
    }
    
    func sendKey(_ key: WebOSKeyTarget) {
        guard let request = key.request else {
            return
        }
        let message = URLSessionWebSocketTask.Message.data(request)
        sendURLSessionWebSocketTaskMessage(message, task: secondaryWebSocketTask)
    }
    
    func sendKey(_ data: Data) {
        let message = URLSessionWebSocketTask.Message.data(data)
        sendURLSessionWebSocketTaskMessage(message, task: secondaryWebSocketTask)
    }
    
    func disconnect(error: Error? = nil) {
        secondaryWebSocketTask?.cancel(with: .goingAway, reason: nil)
        primaryWebSocketTask?.cancel(with: .goingAway, reason: nil)
        delegate?.didDisconnect(with: error)
    }
    
    deinit {
        disconnect()
    }
}

private extension WebOSClient {
    func connect(
        _ url: URL,
        task: inout URLSessionWebSocketTask?
    ) {
        task = urlSession?.webSocketTask(with: url)
        task?.resume()
    }
    
    func sendURLSessionWebSocketTaskMessage(
        _ message: URLSessionWebSocketTask.Message,
        task: URLSessionWebSocketTask?
    ) {
        task?.send(message) { [weak self] error in
            if let error {
                self?.handleError(error)
            }
        }
    }
    
    func listen(
        _ completion: @escaping (Result<WebOSResponse, Error>) -> Void
    ) {
        primaryWebSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let response):
                self?.handle(response, completion: completion)
                self?.listen(completion)
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }
    
    func handle(
        _ response: URLSessionWebSocketTask.Message,
        completion: @escaping (Result<WebOSResponse, Error>) -> Void
    ) {
        if case .string(let json) = response {
            delegate?.didReceive(json)
        }
        guard let response = response.decode(),
              let type = response.type,
              let responseType = WebOSResponseType(rawValue: type) else {
            completion(.failure(NSError(domain: "WebOSClient: Unkown response type.", code: 0)))
            return
        }
        switch responseType {
        case .error:
            let errorMessage = response.error ?? "WebOSClient: Unknown error."
            completion(.failure(NSError(domain: errorMessage, code: 0, userInfo: nil)))
        case .registered:
            if let clientKey = response.payload?.clientKey {
                delegate?.didRegister(with: clientKey)
                pointerRequestId = send(.getPointerInputSocket)
            }
            fallthrough
        default:
            if response.payload?.pairingType == .prompt {
                delegate?.didPrompt()
            }
            if let socketPath = response.payload?.socketPath,
               let url = URL(string: socketPath),
               response.id == pointerRequestId {
                connect(url, task: &secondaryWebSocketTask)
            }
            completion(.success(response))
        }
    }
    
    func handleError(_ error: Error?) {
        if let error = error as NSError? {
            if error.code == 57 || error.code == 60 || error.code == 54 {
                delegate?.didDisconnect(with: error)
            } else {
                delegate?.didReceive(.failure(error))
            }
        }
    }
}

extension WebOSClient: URLSessionWebSocketDelegate {
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        guard webSocketTask === primaryWebSocketTask else {
            return
        }
        delegate?.didConnect()
        listen { [weak self] result in
            self?.delegate?.didReceive(result)
        }
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        guard webSocketTask === primaryWebSocketTask else {
            return
        }
        delegate?.didDisconnect(with: nil)
    }
}
