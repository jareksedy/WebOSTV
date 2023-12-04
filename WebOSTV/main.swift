//
//  main.swift
//  WebOSTV
//
//  Created by Ярослав on 29.11.2023.
//

import Foundation

let webOSClient = WebOSClient(url: URL(string: "wss://192.168.8.10:3001"))
webOSClient.connect()
dispatchMain()
