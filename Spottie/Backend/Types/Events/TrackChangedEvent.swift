//
//  TrackChangedEvent.swift
//  Spottie
//
//  Created by Lee Jun Kit on 22/5/21.
//

struct TrackChangedEvent: Codable {
    var uri: String
    var track: TrackObject?
}
