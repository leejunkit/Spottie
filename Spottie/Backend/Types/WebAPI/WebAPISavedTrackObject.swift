//
//  WebAPISavedTrackObject.swift
//  WebAPISavedTrackObject
//
//  Created by Lee Jun Kit on 21/8/21.
//

import Foundation

struct WebAPISavedTrackObject: Decodable {
    var addedAt: Date
    var track: WebAPITrackObject
}
