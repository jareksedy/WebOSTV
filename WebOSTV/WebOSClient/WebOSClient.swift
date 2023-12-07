//
//  WebOSClient.swift
//  WebOSTV
//
//  Created by Ярослав on 29.11.2023.
//

import Foundation

protocol WebOSClientProtocol {
    var delegate: WebOSClientDelegate? { get set }
    @discardableResult func send(_ target: WebOSTarget) -> String?
    func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode)
}

protocol WebOSClientDelegate: AnyObject {
    func didReceive(_ result: Result<WebOSResponse, Error>)
}

class WebOSClient: NSObject, WebOSClientProtocol {
    private var urlSession: URLSession?
    private var webSocketTask: URLSessionWebSocketTask?
    weak var delegate: WebOSClientDelegate?
    
    init(url: URL?) {
        super.init()
        guard let url else {
            assertionFailure("Device URL is nil. Terminating.")
            return
        }
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        listen { [weak self] result in
            self?.delegate?.didReceive(result)
        }
    }
    
    @discardableResult
    func send(_ target: WebOSTarget) -> String? {
        guard let json = target.json else { return nil }
        let message = URLSessionWebSocketTask.Message.string(json)
        webSocketTask?.send(message) { error in
            if let error = error {
                print(error)
            }
        }
        return target.request.id
    }
    
    func disconnect(
        with closeCode: URLSessionWebSocketTask.CloseCode = .goingAway
    ) {
        webSocketTask?.cancel(with: closeCode, reason: nil)
    }
}

private extension WebOSClient {
    func listen(
        _ completion: @escaping (Result<WebOSResponse, Error>) -> Void
    ) {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let webOSResponse = try response.decode()
                    try self?.handle(webOSResponse, completion: completion)
                } catch {
                    completion(.failure(error))
                }
                self?.listen(completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func handle(
        _ webOSResponse: WebOSResponse?,
        completion: @escaping (Result<WebOSResponse, Error>) -> Void
    ) throws {
        guard let responseType = webOSResponse?.type else {
            throw NSError(domain: "Unknown response type.", code: 0, userInfo: nil)
        }
        switch responseType {
        case "error":
            let errorMessage = webOSResponse?.error ?? "Unknown error"
            completion(.failure(NSError(domain: errorMessage, code: 0, userInfo: nil)))
        default:
            completion(.success(webOSResponse!))
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
