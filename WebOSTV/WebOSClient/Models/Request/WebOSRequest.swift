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
    
    init(
        type: RequestType,
        id: String? = nil,
        uri: String? = nil,
        payload: WebOSRequestPayload? = nil
    ) {
        self.type = type.rawValue
        self.id = id
        self.uri = uri
        self.payload = payload
    }
}
