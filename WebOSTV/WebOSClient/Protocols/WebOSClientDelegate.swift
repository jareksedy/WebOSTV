//
//  WebOSClientDelegate.swift
//  WebOSTV
//
//  Created by Ярослав on 09.12.2023.
//

import Foundation

protocol WebOSClientDelegate: AnyObject {
    func didPrompt()
    func didConnect(with clientKey: String)
    func didReceive(_ result: Result<WebOSResponse, Error>)
    func didReceive(_ json: String)
}

extension WebOSClientDelegate {
    func didPrompt() {}
    func didReceive(_ result: Result<WebOSResponse, Error>) {}
    func didReceive(_ json: String) {}
}
