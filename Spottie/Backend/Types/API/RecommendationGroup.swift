//
//  RecommendationGroup.swift
//  Spottie
//
//  Created by Lee Jun Kit on 7/6/21.
//

import Foundation

struct RecommendationGroup: Decodable, Hashable, Identifiable {
    var id: String
    var name: String
    var rendering: String
    var items: [RecommendationItem]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case rendering
        case items
        case content
    }
    
    struct Content: Decodable {
        var items: [RecommendationItem]
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try values.decode(String.self, forKey:.id)
        self.name = try values.decode(String.self, forKey:.name)
        self.rendering = try values.decode(String.self, forKey:.rendering)
        
        let contentContainer = try values.decode(Content.self, forKey:.content)
        self.items = contentContainer.items
    }
}
