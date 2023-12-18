//
//  WebOSRequest.swift
//  WebOSTV
//
//  Created by Ярослав on 02.12.2023.
//

import Foundation

struct WebOSRequest: Codable {
    var type: String
    var id: String?
    var uri: String?
    var payload: WebOSRequestPayload?
    
    private var uuid: String {
        return UUID().uuidString.lowercased()
    }
    
    var json: String? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) { return jsonString }
        } catch {
            print("Error encoding JSON: \(error)")
        }
        return nil
    }
    
    init(
        type: RequestType,
        id: String? = nil,
        uri: String? = nil,
        payload: WebOSRequestPayload? = nil
    ) {
        self.type = type.rawValue
        self.id = id == nil ? uuid : id
        self.uri = uri
        self.payload = payload
    }
}
