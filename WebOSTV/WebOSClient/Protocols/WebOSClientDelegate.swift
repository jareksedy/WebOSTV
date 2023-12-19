//
//  WebOSClientDelegate.swift
//  WebOSTV
//
//  Created by Ярослав on 09.12.2023.
//

import Foundation

protocol WebOSClientDelegate: AnyObject {
    func didConnect(task: URLSessionWebSocketTask)
    func didPrompt()
    func didRegister(with clientKey: String)
    func didReceive(_ result: Result<WebOSResponse, Error>)
    func didReceive(_ json: String)
    func didDisconnect(
        task: URLSessionWebSocketTask,
        closeCode: URLSessionWebSocketTask.CloseCode
    )
}

extension WebOSClientDelegate {
    func didConnect(task: URLSessionWebSocketTask) {}
    func didPrompt() {}
    func didReceive(_ result: Result<WebOSResponse, Error>) {}
    func didReceive(_ json: String) {}
    func didDisconnect(
        task: URLSessionWebSocketTask,
        closeCode: URLSessionWebSocketTask.CloseCode
    ) {}
}
