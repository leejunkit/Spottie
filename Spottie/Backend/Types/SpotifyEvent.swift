//
//  SpotifyEvent.swift
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

enum EventData {
    case contextChanged(ContextChangedEvent)
    case trackChanged(TrackChangedEvent)
    case playbackEnded(Nothing)
    case playbackPaused(PlaybackPausedEvent)
    case playbackResumed(PlaybackResumedEvent)
    case volumeChanged(VolumeChangedEvent)
    case trackSeeked(TrackSeekedEvent)
    case metadataAvailable(MetadataAvailableEvent)
    case playbackHaltStateChanged(Nothing)
    case sessionCleared(Nothing)
    case sessionChanged(Nothing)
    case inactiveSession(InactiveSessionEvent)
    case connectionDropped(Nothing)
    case connectionEstablished(Nothing)
    case panic(Nothing)
}

struct SpotifyEvent: Decodable {
    var event: EventType
    var data: EventData
    enum CodingKeys: String, CodingKey {
        case event
        case data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let eventName = EventType(rawValue: try values.decode(String.self, forKey:.event)) else {
            throw SpottieError.invalidEventName
        }
        
        event = eventName
        let container = try decoder.singleValueContainer()
        switch event {
        case .contextChanged:
            data = EventData.contextChanged(try container.decode(ContextChangedEvent.self))
        case .trackChanged:
            data = EventData.trackChanged(try container.decode(TrackChangedEvent.self))
        case .playbackEnded:
            data = EventData.playbackEnded(Nothing())
        case .playbackPaused:
            data = EventData.playbackPaused(try container.decode(PlaybackPausedEvent.self))
        case .playbackResumed:
            data = EventData.playbackResumed(try container.decode(PlaybackResumedEvent.self))
        case .volumeChanged:
            data = EventData.volumeChanged(try container.decode(VolumeChangedEvent.self))
        case .trackSeeked:
            data = EventData.trackSeeked(try container.decode(TrackSeekedEvent.self))
        case .metadataAvailable:
            data = EventData.metadataAvailable(try container.decode(MetadataAvailableEvent.self))
        case .playbackHaltStateChanged:
            data = EventData.playbackHaltStateChanged(Nothing())
        case .sessionCleared:
            data = EventData.sessionCleared(Nothing())
        case .sessionChanged:
            data = EventData.sessionChanged(Nothing())
        case .inactiveSession:
            data = EventData.inactiveSession(try container.decode(InactiveSessionEvent.self))
        case .connectionDropped:
            data = EventData.connectionDropped(Nothing())
        case .connectionEstablished:
            data = EventData.connectionEstablished(Nothing())
        case .panic:
            data = EventData.panic(Nothing())
        }
    }
}
