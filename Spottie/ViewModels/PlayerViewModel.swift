//
//  SpotifyState.swift
//  Spottie
//
//  Created by Lee Jun Kit on 22/5/21.
//

import Foundation
import Combine

class PlayerViewModel: PlayerStateProtocol {
    @Published var volumePercent: Float = 0.0
    @Published var isPlaying = false
    @Published var durationMs = 1
    @Published var progressMs = 0
    @Published var trackName = ""
    @Published var artistName = ""
    @Published var artworkURL: URL?
    @Published var isShuffling = false
    @Published var repeatMode = RepeatMode.none
    
    private var cancellables = [AnyCancellable]()
    private var eventBroker: EventBroker
    
    init(_ eventBroker: EventBroker) {
        self.eventBroker = eventBroker
        let token = SpotifyAPI.currentPlayerState().sink(receiveCompletion: {[weak self] status in
            if case .failure(let error) = status {
                print(error)
            } else {
                guard let self = self else { return }
                
                // subscribe to events
                eventBroker.onEventReceived.sink(receiveValue: {[weak self] event in
                    guard let self = self else { return }
                    self.onEventReceived(event: event)
                }).store(in: &self.cancellables)
            }
        }) {[weak self] context in
            guard let self = self else { return }
            if let ctx = context {
                self.handleInitialStateUpdate(context: ctx)
            }
        }
        
        token.store(in: &cancellables)
        
        
    }
    
    func handleInitialStateUpdate(context ctx: CurrentlyPlayingContextObject) {
        self.volumePercent = ctx.device.volumePercent
        self.isPlaying = ctx.isPlaying
        self.trackName = ctx.item.name
        self.artistName = ctx.item.artists[0].name
        self.artworkURL = ctx.item.album.getImageURL(.medium)
        self.durationMs = ctx.item.durationMs
        self.progressMs = ctx.progressMs
    }
    
    func onEventReceived(event: SpotifyEvent) {
        switch (event.data) {
        case let .volumeChanged(volumeChangedEvent):
            self.volumePercent = volumeChangedEvent.value
        case .playbackEnded(_):
            self.isPlaying = false
        case let .playbackPaused(playbackPausedEvent):
            self.progressMs = playbackPausedEvent.trackTime
            self.isPlaying = false
        case let .playbackResumed(playbackResumedEvent):
            self.isPlaying = true
            self.progressMs = playbackResumedEvent.trackTime
        case let .trackSeeked(trackSeekedEvent):
            self.progressMs = trackSeekedEvent.trackTime
        case let .trackChanged(trackChangedEvent):
            self.progressMs = 0
            self.isPlaying = true
            if let track = trackChangedEvent.track {
                self.trackName = track.name
                self.artistName = track.artist[0].name
            }
        case let .metadataAvailable(metadataAvailableEvent):
            self.trackName = metadataAvailableEvent.track.name
            self.artistName = metadataAvailableEvent.track.artist[0].name
            self.artworkURL = metadataAvailableEvent.track.album.coverGroup.getArtworkURL()
            self.durationMs = metadataAvailableEvent.track.duration
        default:
            break;
        }
    }
    
    private func connectNothingPublisher(_ publisher: AnyPublisher<Nothing?, Error>) {
        publisher.sink { _ in } receiveValue: { _ in }.store(in: &cancellables)
    }
    
    func togglePlayPause() {
        var apiCall: AnyPublisher<Nothing?, Error>;
        if self.isPlaying {
            apiCall = SpotifyAPI.pause()
        } else {
            apiCall = SpotifyAPI.resume()
        }
        
        self.connectNothingPublisher(apiCall)
    }
    
    func nextTrack() {
        self.connectNothingPublisher(SpotifyAPI.nextTrack())
    }
    
    func previousTrack() {
        SpotifyAPI.previousTrack().sink { _ in
            // manually reset the progress to 0
            self.progressMs = 0
        } receiveValue: { _ in }.store(in: &cancellables)
    }
    
    func seek(toPercent: Double) {
        // calculate posMs
        let posMs = Int(Double(self.durationMs) * toPercent)
        self.connectNothingPublisher(SpotifyAPI.seek(posMs: posMs))
    }
    
    func setVolume(volumePercent: Float) {
        self.volumePercent = volumePercent
        self.connectNothingPublisher(SpotifyAPI.setVolume(volumePercent: volumePercent))
    }
    
    func toggleShuffle() {
        self.isShuffling = !self.isShuffling
        self.connectNothingPublisher(SpotifyAPI.setShuffle(shuffle: self.isShuffling))
    }
    
    func cycleRepeatMode() {
        switch self.repeatMode {
        case .none:
            self.repeatMode = .track
        case .track:
            self.repeatMode = .context
        case .context:
            self.repeatMode = .none
        }
        
        self.connectNothingPublisher(SpotifyAPI.setRepeatMode(mode: self.repeatMode))
    }
}
