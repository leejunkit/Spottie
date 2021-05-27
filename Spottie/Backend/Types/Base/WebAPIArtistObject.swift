//
//  WebAPIArtistObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/5/21.
//

struct WebAPIArtistObject: Codable {
    var id: String
    var uri: String
    var name: String
    var images: [WebAPIImageObject]
    var popularity: Int
}
