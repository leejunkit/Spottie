//
//  RecommendationItem.swift
//  Spottie
//
//  Created by Lee Jun Kit on 7/6/21.
//

import Foundation

enum RecommendationItemData {
    case link(RecommendationLink)
    case album(WebAPISimplifiedAlbumObject)
    case artist(WebAPIArtistObject)
    case playlist(WebAPIPlaylistObject)
}

struct RecommendationItem: Hashable, Identifiable, Decodable {
    static func == (lhs: RecommendationItem, rhs: RecommendationItem) -> Bool {
        if lhs.type == rhs.type {
            if (lhs.type == .unknown) {
                return true
            }
        }
        
        return lhs.id == rhs.id;
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    enum RecommendationItemType: String, Decodable, CaseIterable {
        case link
        case album
        case artist
        case playlist
        case unknown
    }
    
    var id: String
    var type: RecommendationItemType
    var data: RecommendationItemData?
    
    enum CodingKeys: String, CodingKey {
        case type
        case data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        var typeRawValue = try values.decode(String.self, forKey:.type)
        print("Encountered RecommendationItemType \(typeRawValue)")
        
        if (!(RecommendationItemType.allCases.map {
            $0.rawValue
        }.contains(typeRawValue))) {
            typeRawValue = "unknown"
        }
        
        self.type = RecommendationItemType(rawValue: typeRawValue)!
           
        // attempt to decode RecommendationItemData
        let container = try decoder.singleValueContainer()
        switch(self.type) {
        case .link:
            data = RecommendationItemData.link(try container.decode(RecommendationLink.self))
            self.id = "spotify:link:\(UUID().uuidString)"
        case .artist:
            let artist = try container.decode(WebAPIArtistObject.self)
            self.id = artist.uri
            data = RecommendationItemData.artist(artist)
        case .album:
            let album = try container.decode(WebAPISimplifiedAlbumObject.self)
            self.id = album.uri
            data = RecommendationItemData.album(album)
        case .playlist:
            let playlist = try container.decode(WebAPIPlaylistObject.self)
            self.id = playlist.uri
            data = RecommendationItemData.playlist(playlist)
        case .unknown:
            self.id = "spotify:unknown:\(UUID().uuidString)"
            break
        }
    }
}
