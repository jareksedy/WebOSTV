//
//  Dictionary+JSON.swift
//  WebOSTV
//
//  Created by Ярослав on 29.11.2023.
//

import Foundation

extension Dictionary where Key == String, Value: Any {
    func toJSONString(prettyPrinted: Bool = false) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self,
                                                      options: prettyPrinted ? .prettyPrinted : [])
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Error converting dictionary to JSON: \(error)")
            return nil
        }
    }
}
