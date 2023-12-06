//
//  WebOSResponse.swift
//  WebOSTV
//
//  Created by Ярослав on 06.12.2023.
//

import Foundation

struct WebOSResponse: Codable {
    var type: String?
    //var id: String
    var error: String?
    var payload: WebOSResponsePayload?
}
