//
//  String+.swift
//  WebOSTV
//
//  Created by Ярослав on 05.12.2023.
//

import Foundation

extension String {
    static let prompt = "PROMPT"
}

extension String {
    func decode<T: Codable>() throws -> T {
        guard let data = self.data(using: .utf8) else {
            throw NSError(domain: "Invalid string encoding", code: 0, userInfo: nil)
        }
        do {
            let decoder = JSONDecoder()
            let decodedObject = try decoder.decode(T.self, from: data)
            return decodedObject
        } catch {
            throw error
        }
    }
}
