//
//  WebOSClient.swift
//  WebOSTV
//
//  Created by Ярослав on 29.11.2023.
//

import Foundation

protocol WebOSClientProtocol {
    func connect(with clientKey: String?)
    func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode)
    func toast(message: String, iconData: Data?, iconExtension: String?)
}

protocol WebOSClientDelegate: AnyObject {
    func didConnect(with clientKey: String?, error: Error?)
    func didReceive(response: Codable?, error: Error?)
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
    
    func connect(with clientKey: String?) {
        send(makeRegistrationRequest(clientKey: clientKey))
        listenForClientKey { [weak self] result in
            switch result {
            case .success(let response): 
                self?.delegate?.didConnect(with: response.payload?.clientKey, error: nil)
            case .failure(let error):
                self?.delegate?.didConnect(with: nil, error: error)
            }
        }
    }
    
    func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode = .goingAway) {
        webSocketTask?.cancel(with: closeCode, reason: nil)
    }
    
    func toast(message: String, iconData: Data?, iconExtension: String?) {
        let payload = WebOSRequestPayload(
            message: message,
            iconData: iconData,
            iconExtension: iconExtension
        )
        let request = WebOSRequest(
            type: "request",
            id: id,
            uri: "ssap://system.notifications/createToast",
            payload: payload
        )
        send(request)
        listen { [weak self] result in
            switch result {
            case .success(let response):
                self?.delegate?.didReceive(response: response, error: nil)
            case .failure(let error):
                self?.delegate?.didReceive(response: nil, error: error)
            }
        }
    }
}

private extension WebOSClient {
    func makeRegistrationRequest(clientKey: String?) -> WebOSRequest {
        let payload = WebOSRequestPayload(
            forcePairing: false,
            manifest: WebOSRequestManifest(),
            pairingType: "PROMPT",
            clientKey: clientKey
        )
        return .init(type: "register", id: id, payload: payload)
    }
    
    func send(_ request: Codable) {
        guard let requestJSON = request.toJSONString() else { return }
        let message = URLSessionWebSocketTask.Message.string(requestJSON)
        webSocketTask?.send(message) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func listen(
        completion: @escaping (Result<WebOSResponse, Error>) -> Void
    ) {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let webOSResponse = try self?.decodeRegistrationResponse(from: response)
                    try self?.handleResponse(webOSResponse, completion: completion)
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func listenForClientKey(
        completion: @escaping (Result<WebOSResponse, Error>) -> Void
    ) {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let webOSResponse = try self?.decodeRegistrationResponse(from: response)
                    try self?.handleRegistrationResponse(webOSResponse, completion: completion)
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func decodeRegistrationResponse(
        from response: URLSessionWebSocketTask.Message
    ) throws -> WebOSResponse? {
        switch response {
        case .string(let string):
            do {
                return try string.decode()
            } catch {
                throw error
            }
        case .data:
            throw NSError(domain: "Unknown response type (binary data)", code: 0, userInfo: nil)
        @unknown default:
            throw NSError(domain: "Unknown response type", code: 0, userInfo: nil)
        }
    }
    
    func handleResponse(
        _ webOSResponse: WebOSResponse?,
        completion: @escaping (Result<WebOSResponse, Error>) -> Void
    ) throws {
        guard let responseType = webOSResponse?.type else {
            throw NSError(domain: "Response type is missing", code: 0, userInfo: nil)
        }
        
        switch responseType {
        case "error":
            let errorMessage = webOSResponse?.error ?? "Unknown error"
            completion(.failure(NSError(domain: errorMessage, code: 0, userInfo: nil)))
        default:
            completion(.success(webOSResponse!))
        }
    }
    
    func handleRegistrationResponse(
        _ webOSResponse: WebOSResponse?,
        completion: @escaping (Result<WebOSResponse, Error>) -> Void
    ) throws {
        guard let responseType = webOSResponse?.type else {
            throw NSError(domain: "Response type is missing", code: 0, userInfo: nil)
        }
        
        switch responseType {
        case "registered":
            completion(.success(webOSResponse!))
        case "error":
            let errorMessage = webOSResponse?.error ?? "Unknown error"
            completion(.failure(NSError(domain: errorMessage, code: 0, userInfo: nil)))
        default:
            listenForClientKey(completion: completion)
        }
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
