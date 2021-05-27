//
//  CoverGroupObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 22/5/21.
//
import Foundation

struct CoverGroupObject: Codable {
    var image: [ImageObject]
    func getArtworkURL() -> URL? {
        let fileId = self.image[0].fileId.lowercased()
        return URL(string: "https://i.scdn.co/image/\(fileId)")
    }
}
