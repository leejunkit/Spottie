//
//  WebAPITrackObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/5/21.
//

struct WebAPITrackObject: Decodable, Identifiable {
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
    
    var artistString: String {
        get {
            return artists.map({$0.name}).joined(separator: ", ")
        }
    }
    
    var durationString: String {
        get {
            let durationSeconds = Double(durationMs / 1000)
            return DurationFormatter.shared.format(durationSeconds)
        }
    }
}
