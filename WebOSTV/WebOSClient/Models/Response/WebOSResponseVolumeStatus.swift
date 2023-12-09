//
//  WebOSResponseVolumeStatus.swift
//  WebOSTV
//
//  Created by Ярослав on 09.12.2023.
//

import Foundation

struct WebOSResponseVolumeStatus: Codable {
    var volumeLimitable: Bool?
    var activeStatus: Bool?
    var maxVolume: Int?
    var volumeLimiter: String?
    var soundOutput: String?
    var volume: Int?
    var mode: String?
    var externalDeviceControl: Bool?
    var muteStatus: Bool?
    var volumeSyncable: Bool?
    var adjustVolume: Bool?
}
