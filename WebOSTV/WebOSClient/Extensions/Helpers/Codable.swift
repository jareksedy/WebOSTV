//
//  Encodable+encode.swift
//  WebOSTV
//
//  Created by Ярослав on 18.12.2023.
//

import Foundation

extension Encodable {
    func encode() throws -> String {
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(self)
            guard let json = String(data: encodedData, encoding: .utf8) else {
                throw NSError(domain: "Error encoding string", code: 0, userInfo: nil)
            }
            return json
        } catch {
            throw error
        }
    }
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
