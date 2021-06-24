//
//  WebAPITrackObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/5/21.
//

struct WebAPITrackObject: Decodable {
    var id: String
    var uri: String
    var album: WebAPISimplifiedAlbumObject
    var artists: [WebAPISimplifiedArtistObject]
    var durationMs: Int
    var explicit: Bool
    var name: String
    var popularity: Int
    var discNumber: Int
    var trackNumber: Int
}
