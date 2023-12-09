//
//  WebOSTarget.swift
//  WebOSTV
//
//  Created by Ярослав on 06.12.2023.
//

import Foundation

enum WebOSTarget {
    case connect(clientKey: String?)
    case createToast(message: String, iconData: Data? = nil, iconExtension: String? = nil)
}
