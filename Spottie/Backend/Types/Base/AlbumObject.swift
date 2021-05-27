//
//  AlbumObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 22/5/21.
//

struct AlbumObject: Codable {
    var gid: String
    var name: String
    var artist: ArtistObject
    var label: String
    var date: DateObject
    var coverGroup: CoverGroupObject
}
