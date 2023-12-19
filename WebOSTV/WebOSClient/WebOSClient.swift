//
//  WebOSClient.swift
//  WebOSTV
//
//  Created by Ярослав on 29.11.2023.
//

import Foundation

class WebOSClient: NSObject, WebOSClientProtocol {
    private var urlSession: URLSession?
    private var commonWebSocketTask: URLSessionWebSocketTask?
    private var pointerWebSocketTask: URLSessionWebSocketTask?
    private var pointerRequestId: String?
    var isConnected: Bool = false
    weak var delegate: WebOSClientDelegate?
    
    init(url: URL?, delegate: WebOSClientDelegate? = nil) {
        super.init()
        guard let url else {
            assertionFailure("Invalid device URL. Terminating.")
            return
        }
        self.delegate = delegate
        connect(url: url)
    }
    
    func connect(url: URL) {
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        connect(url, task: &commonWebSocketTask)
    }
    
    @discardableResult
    func send(_ target: WebOSTarget, id: String) -> String? {
        guard let json = target.request.jsonWithId(id) else {
            return nil
        }
        let message = URLSessionWebSocketTask.Message.string(json)
        sendURLSessionWebSocketTaskMessage(message, task: commonWebSocketTask)
        return id
    }
    
    func send(_ jsonRequest: String) {
        let message = URLSessionWebSocketTask.Message.string(jsonRequest)
        sendURLSessionWebSocketTaskMessage(message, task: commonWebSocketTask)
    }
    
    func sendKey(_ key: WebOSKeyTarget) {
        guard let request = key.request else {
            return
        }
        let message = URLSessionWebSocketTask.Message.data(request)
        sendURLSessionWebSocketTaskMessage(message, task: pointerWebSocketTask)
    }
    
    func sendKey(_ data: Data) {
        let message = URLSessionWebSocketTask.Message.data(data)
        sendURLSessionWebSocketTaskMessage(message, task: pointerWebSocketTask)
    }
    
    func disconnect(
        with closeCode: URLSessionWebSocketTask.CloseCode = .goingAway
    ) {
        pointerWebSocketTask?.cancel(with: closeCode, reason: nil)
        commonWebSocketTask?.cancel(with: closeCode, reason: nil)
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
            if let error = error {
                self?.delegate?.didReceive(.failure(error))
            }
        }
    }
    
    func listen(
        _ completion: @escaping (Result<WebOSResponse, Error>) -> Void
    ) {
        commonWebSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let response):
                self?.handle(response, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
            self?.listen(completion)
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
                delegate?.didConnect(with: clientKey)
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
                connect(url, task: &pointerWebSocketTask)
            }
            completion(.success(response))
        }
    }
}

extension WebOSClient: URLSessionWebSocketDelegate {
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        isConnected = true
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
        isConnected = false
    }
}
