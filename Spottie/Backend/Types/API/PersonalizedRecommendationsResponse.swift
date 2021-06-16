//
//  PersonalizedRecommendationsResponse.swift
//  Spottie
//
//  Created by Lee Jun Kit on 8/6/21.
//

import Foundation

struct PersonalizedRecommendationsResponse: Decodable {
    var content: Content
    
    struct Content: Decodable {
        var items: [RecommendationGroup]
    }
}
