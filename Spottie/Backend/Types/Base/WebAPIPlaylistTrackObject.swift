//
//  WebAPIPlaylistTrackObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 8/6/21.
//

import Foundation

struct WebAPIPlaylistTrackObject: Decodable {
    var addedAt: String
    var addedBy: WebAPIPublicUserObject
    var isLocal: Bool
    var track: WebAPITrackObject
}
