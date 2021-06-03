//
//  PlayerStateProtocol.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/5/21.
//

import Foundation
import Combine

protocol PlayerStateProtocol: ObservableObject {
    var volumePercent: Float { get set }
    var isPlaying: Bool { get set }
    var trackName: String { get set }
    var artistName: String { get set }
    var artworkURL: URL? { get set }
    var durationMs: Int { get set }
    var progressMs: Int { get set }
    var isShuffling: Bool { get set }
    var repeatMode: RepeatMode { get set }
    
    func togglePlayPause() -> Void
    func nextTrack() -> Void
    func previousTrack() -> Void
    func seek(toPercent: Double) -> Void
    func setVolume(volumePercent: Float) -> Void
    func toggleShuffle() -> Void
    func cycleRepeatMode() -> Void
}
