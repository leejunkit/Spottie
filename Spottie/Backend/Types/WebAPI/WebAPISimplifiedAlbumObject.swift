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

struct WebAPISimplifiedAlbumObject: Codable {
    var id: String
    var uri: String
    var albumType: AlbumType
    var artists: [WebAPISimplifiedArtistObject]
    var images: [WebAPIImageObject]
    var name: String
    var releaseDate: String
    var releaseDatePrecision: ReleaseDatePrecision
    var totalTracks: Int
    
    func getArtworkURL() -> URL {
        if (self.images.isEmpty) {
            return URL(string: "https://misc.scdn.co/liked-songs/liked-songs-640.png")!
        }
        
        return URL(string: self.images[0].url)!
    }
}
