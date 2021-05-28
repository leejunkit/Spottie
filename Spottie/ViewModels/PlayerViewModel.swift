//
//  SpotifyState.swift
//  Spottie
//
//  Created by Lee Jun Kit on 22/5/21.
//

import Foundation
import Combine

class PlayerViewModel: PlayerStateProtocol {
    @Published var isPlaying = false
    @Published var durationMs = 0
    @Published var progressMs = 0
    @Published var trackName = ""
    @Published var artistName = ""
    @Published var artworkURL: URL?
    
    
    private var cancellables = [AnyCancellable]()
    private var eventBroker: EventBroker
    
    init(_ eventBroker: EventBroker) {
        self.eventBroker = eventBroker
        let token = SpotifyAPI.currentPlayerState().sink(receiveCompletion: {[weak self] status in
            if case .failure(let error) = status {
                print(error)
            }
            
            guard let self = self else { return }
            
            // subscribe to events
            eventBroker.onEventReceived.sink(receiveValue: {[weak self] event in
                guard let self = self else { return }

                switch (event.data) {
                case .playbackEnded(_):
                    self.isPlaying = false
                case let .playbackPaused(playbackPausedEvent):
                    self.progressMs = playbackPausedEvent.trackTime
                    self.isPlaying = false
                case let .playbackResumed(playbackResumedEvent):
                    self.isPlaying = true
                    self.progressMs = playbackResumedEvent.trackTime
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
                
                print(" in event recevied: self.durationMs: \(self.durationMs) self.progressMs: \(self.progressMs)")
            }).store(in: &self.cancellables)
        }) {[weak self] context in
            guard let self = self else { return }
            if let ctx = context {
                self.isPlaying = ctx.isPlaying
                self.trackName = ctx.item.name
                self.artistName = ctx.item.artists[0].name
                self.artworkURL = ctx.item.album.getArtworkURL()
                self.durationMs = ctx.item.durationMs
                self.progressMs = ctx.progressMs
            }
            
            print(" in value recevied: self.durationMs: \(self.durationMs) self.progressMs: \(self.progressMs)")
        }
        
        token.store(in: &cancellables)
    }
    
    func togglePlayPause() {
        var apiCall: AnyPublisher<Nothing?, Error>;
        if self.isPlaying {
            apiCall = SpotifyAPI.pause()
        } else {
            apiCall = SpotifyAPI.resume()
        }
        
        apiCall.print().sink { _ in } receiveValue: { _ in }.store(in: &cancellables)
    }
    
    func nextTrack() {
        SpotifyAPI.nextTrack().sink { _ in } receiveValue: { _ in }.store(in: &cancellables)
    }
    
    func previousTrack() {
        SpotifyAPI.previousTrack().sink { _ in } receiveValue: { _ in }.store(in: &cancellables)
    }
}
