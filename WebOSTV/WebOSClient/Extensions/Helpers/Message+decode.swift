//
//  Message+.swift
//  WebOSTV
//
//  Created by Ярослав on 07.12.2023.
//

import Foundation

extension URLSessionWebSocketTask.Message {
    func decode() -> WebOSResponse? {
        switch self {
        case .string(let string):
            print()
            print(string)
            print()
            return try? string.decode()
        case .data:
            return nil
        @unknown default:
            return nil
        }
    }
}
