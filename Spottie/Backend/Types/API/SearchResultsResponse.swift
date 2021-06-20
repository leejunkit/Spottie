//
//  SearchResultsResponse.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/6/21.
//

import Foundation

struct SearchResultsResponse: Decodable {
    let albums: WebAPIPagingObject<WebAPISimplifiedAlbumObject>
    let artists: WebAPIPagingObject<WebAPISimplifiedAlbumObject>
    let tracks: WebAPIPagingObject<WebAPITrackObject>
    let playlists: WebAPIPagingObject<WebAPIPlaylistObject>
}
