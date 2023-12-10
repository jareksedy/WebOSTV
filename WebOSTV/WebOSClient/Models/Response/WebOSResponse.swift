//
//  WebOSResponse.swift
//  WebOSTV
//
//  Created by Ярослав on 06.12.2023.
//

import Foundation

struct WebOSResponse: Codable {
    let type: String?
    let id: String?
    let error: String?
    let payload: WebOSResponsePayload?
}
