//
//  WebAPIDeviceObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 3/6/21.
//

import Foundation

struct WebAPIDeviceObject: Codable {
    var id: String
    var isActive: Bool
    var name: String
    var type: String
    var volumePercent: Float
}
