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
    @Published var progressPercent = 0.0
    @Published var trackName = ""
    @Published var artistName = ""
    @Published var artworkURL: URL?
    @Published var isShuffling = false
    @Published var repeatMode = RepeatMode.none
    @Published var isScrubbing = false
    
    private var cancellables = [AnyCancellable]()
    private var eventBroker: EventBroker
    
    private var timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var timerSubscription: AnyCancellable?
    
    init(_ eventBroker: EventBroker) {
        self.eventBroker = eventBroker
        SpotifyAPI.currentPlayerState().sink(receiveCompletion: {_ in
            // subscribe to events
            eventBroker.onEventReceived.sink(receiveValue: { [weak self] event in
                self?.onEventReceived(event: event)
            }).store(in: &self.cancellables)
        }) { [weak self] context in
            if let ctx = context {
                self?.handleInitialStateUpdate(context: ctx)
            }
        }.store(in: &cancellables)
        
        // progress timer to activate only when isPlaying is true
        $isPlaying.sink { [weak self] playing in
            guard let strongSelf = self else { return }
            
            if playing {
                if strongSelf.timerSubscription == nil {
                    strongSelf.timerSubscription = strongSelf.timerPublisher.sink { _ in
                        if !strongSelf.isScrubbing {
                            strongSelf.progressMs += 1000
                        }
                    }
                }
            } else {
                strongSelf.timerSubscription?.cancel()
                strongSelf.timerSubscription = nil
            }
        }.store(in: &cancellables)
        
        // derive percent progress
        Publishers.CombineLatest($progressMs, $durationMs)
        .map({ progressMs, durationMs -> Double in
            if durationMs == 0 {
                return 0.0
            } else {
                return Double(progressMs) / Double(durationMs)
            }
        })
        .sink { [weak self] pc in
            guard let strongSelf = self else { return }
            if !strongSelf.isScrubbing {
                strongSelf.progressPercent = pc
            }
        }
        .store(in: &cancellables)
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
