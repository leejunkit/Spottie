//
//  CurrentTrackResponse.swift
//  Spottie
//
//  Created by Lee Jun Kit on 23/5/21.
//

enum RepeatState: String, Codable {
    case off
    case track
    case context
}

struct CurrentlyPlayingContextObject: Decodable {
    var device: WebAPIDeviceObject
    var isPlaying: Bool
    var shuffleState: Bool
    var repeatState: RepeatState
    var progressMs: Int
    var item: WebAPITrackObject
}
