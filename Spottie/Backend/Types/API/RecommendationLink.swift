//
//  RecommendationLink.swift
//  Spottie
//
//  Created by Lee Jun Kit on 7/6/21.
//

import Foundation

struct RecommendationLink: Decodable {
    var uri: String
    var name: String
    var images: [WebAPIImageObject]
}
