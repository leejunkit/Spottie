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
                switch (event.data) {
                case .playbackEnded(_):
                    fallthrough
                case .playbackPaused(_):
                    self?.isPlaying = false
                case .playbackResumed(_):
                    self?.isPlaying = true
                case let .trackChanged(trackChangedEvent):
                    if let track = trackChangedEvent.track {
                        self?.trackName = track.name
                        self?.artistName = track.artist[0].name
                    }
                case let .metadataAvailable(metadataAvailableEvent):
                    self?.trackName = metadataAvailableEvent.track.name
                    self?.artistName = metadataAvailableEvent.track.artist[0].name
                    self?.artworkURL = metadataAvailableEvent.track.album.coverGroup.getArtworkURL()
                    self?.durationMs = metadataAvailableEvent.track.duration
                    self?.progressMs = 0
                default:
                    break;
                }
            }).store(in: &self.cancellables)
        }) {[weak self] context in
            if let ctx = context {
                self?.isPlaying = ctx.isPlaying
                self?.trackName = ctx.item.name
                self?.artistName = ctx.item.artists[0].name
                self?.artworkURL = ctx.item.album.getArtworkURL()
                self?.durationMs = ctx.item.durationMs
                self?.progressMs = ctx.progressMs
            }
        }
        
        token.store(in: &cancellables)
    }
    
    func onPlayPauseButtonTapped() {
        var apiCall: AnyPublisher<Nothing?, Error>;
        if self.isPlaying {
            apiCall = SpotifyAPI.pause()
        } else {
            apiCall = SpotifyAPI.resume()
        }
        
        apiCall.print().sink { _ in } receiveValue: { _ in }.store(in: &cancellables)
    }
    
    func onNextTrackButtonTapped() {
        SpotifyAPI.nextTrack().sink { _ in } receiveValue: { _ in }.store(in: &cancellables)
    }
    
    func onPreviousTrackButtonTapped() {
        SpotifyAPI.previousTrack().sink { _ in } receiveValue: { _ in }.store(in: &cancellables)
    }
}
