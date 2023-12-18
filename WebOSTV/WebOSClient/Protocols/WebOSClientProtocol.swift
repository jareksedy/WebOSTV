//
//  WebOSClientProtocol.swift
//  WebOSTV
//
//  Created by Ярослав on 09.12.2023.
//

import Foundation

protocol WebOSClientProtocol {
    var delegate: WebOSClientDelegate? { get set }
    @discardableResult func send(_ target: WebOSTarget, id: String?) -> String?
    func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode)
}

extension WebOSClientProtocol {
    @discardableResult func send(_ target: WebOSTarget, id: String? = nil) -> String? {
        send(target, id: nil)
    }
}
