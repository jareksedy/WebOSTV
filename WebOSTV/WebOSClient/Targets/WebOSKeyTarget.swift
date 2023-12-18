//
//  WebOSKeyTarget.swift
//  WebOSTV
//
//  Created by Ярослав on 18.12.2023.
//

import Foundation

enum WebOSKeyTarget {
    case move(dx: Int, dy: Int, down: Int = 0)
    case click
    case scroll(dx: Int, dy: Int)
    // Buttons
    case home
}
