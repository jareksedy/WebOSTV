//
//  WebOSClientProtocol.swift
//  WebOSTV
//
//  Created by Ярослав on 09.12.2023.
//

import Foundation

protocol WebOSClientProtocol {
    var delegate: WebOSClientDelegate? { get set }
    @discardableResult func send(_ target: WebOSTarget) -> String?
    func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode)
}
