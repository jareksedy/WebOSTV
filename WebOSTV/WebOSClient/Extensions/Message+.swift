//
//  Message+.swift
//  WebOSTV
//
//  Created by Ярослав on 07.12.2023.
//

import Foundation

extension URLSessionWebSocketTask.Message {
    func decode() throws -> WebOSResponse? {
        switch self {
        case .string(let string):
            do {
                return try string.decode()
            } catch {
                throw error
            }
        case .data:
            throw NSError(domain: "Unknown binary response type.", code: 0, userInfo: nil)
        @unknown default:
            throw NSError(domain: "Unknown response type.", code: 0, userInfo: nil)
        }
    }
}
