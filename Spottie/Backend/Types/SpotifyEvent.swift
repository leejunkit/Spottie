//
//  WebsocketMessage.swift
//  Spottie
//
//  Created by Lee Jun Kit on 22/5/21.
//

enum EventType: String, Codable {
    case contextChanged
    case trackChanged
    case playbackEnded
    case playbackPaused
    case playbackResumed
    case volumeChanged
    case trackSeeked
    case metadataAvailable
    case playbackHaltStateChanged
    case sessionCleared
    case sessionChanged
    case inactiveSession
    case connectionDropped
    case connectionEstablished
    case panic
}

struct WebsocketMessage: Codable {
    var type: EventType
}
