//
//  FakePlayerViewModel.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/5/21.
//

import Foundation

final class FakePlayerViewModel: PlayerStateProtocol {
    var volumePercent : Float = 0.5
    var isPlaying = false
    var durationMs = 1200
    var progressMs = 3600
    
    var trackName = "Track Name"
    var artistName = "Artist Name"
    var artworkURL = URL(string: "https://i.scdn.co/image/ab67616d00004851a48964b5d9a3d6968ae3e0de")
    
    func previousTrack() {}
    func nextTrack() {}
    func togglePlayPause() {}
    func seek(toPercent: Double) {}
    func setVolume(volumePercent: Float) {}
}
