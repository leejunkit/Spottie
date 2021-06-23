//
//  WebAPIArtistObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/5/21.
//

import Foundation

struct WebAPIArtistObject: Codable {
    var id: String
    var uri: String
    var name: String
    var images: [WebAPIImageObject]
    var popularity: Int
    
    func getArtworkURL() -> URL {
        if (self.images.isEmpty) {
            return URL(string: "https://misc.scdn.co/liked-songs/liked-songs-640.png")!
        }
        
        return URL(string: self.images[0].url)!
    }
}
