//
//  WebAPIImageCollection.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/6/21.
//

import Foundation

protocol WebAPIImageCollection {
    var images: [WebAPIImageObject] { get }
}

extension WebAPIImageCollection {
    func getImageURL(_ forSize: WebAPIImageObject.ImageSize) -> URL {
        if images.isEmpty {
            // return a placeholder
            return URL(string: "https://misc.scdn.co/liked-songs/liked-songs-64.png")!
        }
        
        switch (forSize) {
        case .small:
            return URL(string: images[images.count - 1].url)!
        case .large:
            return URL(string: images[0].url)!
        case .medium:
            if images.count <= 2 {
                return URL(string: images[0].url)!
            } else {
                return URL(string: images[images.count / 2].url)!
            }
        }
    }
}
