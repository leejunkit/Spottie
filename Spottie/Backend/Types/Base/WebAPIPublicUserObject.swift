//
//  WebAPIPublicUserObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 8/6/21.
//

import Foundation

struct WebAPIPublicUserObject: Decodable {
    var id: String
    var uri: String
    var displayName: String?
    var images: [WebAPIImageObject]?
}
