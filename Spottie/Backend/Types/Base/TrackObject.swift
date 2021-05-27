//
//  TrackObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 22/5/21.
//

struct TrackObject: Codable {
    var gid: String
    var name: String
    var album: AlbumObject
    var artist: ArtistObject
    var number: Int
    var discNumber: Int
    var duration: Int
    var popularity: Int    
}
