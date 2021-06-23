//
//  WebAPIPlaylistObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 8/6/21.
//

import Foundation

struct WebAPIPlaylistObject: Decodable {
    var id: String
    var uri: String
    var name: String
    var owner: WebAPIPublicUserObject
    var description: String?
    var images: [WebAPIImageObject]
    var tracks: WebAPIPlaylistTracksRefObject
    
    func getArtworkURL() -> URL {
        if (self.images.isEmpty) {
            return URL(string: "https://misc.scdn.co/liked-songs/liked-songs-640.png")!
        }
        
        return URL(string: self.images[0].url)!
    }
}
