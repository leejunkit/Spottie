//
//  WebAPIPlaylistObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 8/6/21.
//

import Foundation

struct WebAPIPlaylistObject: Decodable, WebAPIImageCollection {
    var id: String
    var uri: String
    var name: String
    var owner: WebAPIPublicUserObject
    var description: String?
    var images: [WebAPIImageObject]
    var tracks: WebAPIPlaylistTracksRefObject
}
