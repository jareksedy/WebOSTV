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
}
