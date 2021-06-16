//
//  RecommendationsObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 7/6/21.
//

import Foundation

struct RecommendationList: Decodable {
    var id: String
    var name: String
    var rendering: String
    var items: [Item]
    
    struct Item: Decodable {
        var type: String
        var name: String
        var uri: String
        var href: String
    }
}
