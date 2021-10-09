//
//  WebAPISimplifiedPlaylistObject.swift
//  WebAPISimplifiedPlaylistObject
//
//  Created by Lee Jun Kit on 22/9/21.
//

import Foundation

struct WebAPISimplifiedPlaylistObject: Decodable, Identifiable, WebAPIImageCollection {
    let collaborative: Bool
    let description: String?
    let id: String
    let uri: String
    let images: [WebAPIImageObject]
    let name: String
    let snapshotId: String
    let tracks: WebAPIPlaylistTracksRefObject
}
