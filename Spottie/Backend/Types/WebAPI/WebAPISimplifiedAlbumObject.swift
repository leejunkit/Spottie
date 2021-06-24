//
//  WebAPISimplifiedArtistObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/5/21.
//

import Foundation

enum AlbumType: String, Codable {
    case album
    case single
    case compilation
}

enum ReleaseDatePrecision: String, Codable {
    case year
    case month
    case day
}

struct WebAPISimplifiedAlbumObject: Decodable, WebAPIImageCollection {
    var id: String
    var uri: String
    var albumType: AlbumType
    var artists: [WebAPISimplifiedArtistObject]
    var images: [WebAPIImageObject]
    var name: String
    var releaseDate: String
    var releaseDatePrecision: ReleaseDatePrecision
    var totalTracks: Int
}
