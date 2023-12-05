//
//  Codable+.swift
//  WebOSTV
//
//  Created by Ярослав on 03.12.2023.
//

import Foundation

extension Encodable {
    func toJSONString(prettyPrinted: Bool = false) -> String? {
        let encoder = JSONEncoder()
        if prettyPrinted { encoder.outputFormatting = .prettyPrinted }
        do {
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) { return jsonString }
        } catch {
            print("Error encoding JSON: \(error)")
        }
        return nil
    }
}
