//
//  TrackProgressSlider.swift
//  Spottie
//
//  Created by Lee Jun Kit on 26/5/21.
//

import SwiftUI
import Combine

struct TrackProgressSlider: View {
    @StateObject var vm2 = ViewModel()
    
    var body: some View {
        HStack {
            VStack {
                Text(vm2.prettyElapsed)
                    .foregroundColor(.secondary)
                    .font(.monospacedDigit(.system(.body))())
            }
            .frame(width: 40)
            
            Slider(
                value: $vm2.progressPercent,
                in: 0...1,
                onEditingChanged: { editing in
                    if (!editing) {
                        vm2.seek(toPercent: vm2.progressPercent)
                    }
                    
                    vm2.isScrubbing = editing
                }
            )
            
            VStack(alignment: .leading) {
                Text(vm2.prettyDuration)
                    .foregroundColor(.secondary)
                    .font(.monospacedDigit(.system(.body))())
            }
            .frame(width: 40)
        }
    }
    
    class ViewModel: ObservableObject {
        @Published var isPlaying = false
        @Published var isScrubbing = false
        @Published var prettyElapsed = "00:00"
        @Published var prettyDuration = "00:00"
        @Published var progressPercent = 0.0 {
            willSet {
                if isScrubbing {
                    let newElapsed = newValue * Double(currentTrackDuration)
                    prettyElapsed = DurationFormatter.shared.format(newElapsed / 1000)
                }
            }
        }
        
        @Inject var playerCore: PlayerCore
        @Inject var webAPI: SpotifyWebAPI
        private var cancellables = [AnyCancellable]()
        
        private var timerPublisher = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
        private var timerSubscription: AnyCancellable?
        
        private var since = Date()
        private var currentTrackDuration = 0
        
        init() {
            playerCore
                .statePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    guard let self = self else { return }
                    guard let state = state else { return }
                    
                    if state.player.state == .playing {
                        self.isPlaying = true
                        if let trackId = state.player.trackId {
                            Task.init {
                                if case let .success(track) = await self.webAPI.getTrack(trackId) {
                                    DispatchQueue.main.async {
                                        self.currentTrackDuration = track.durationMs
                                        self.prettyDuration = track.durationString
                                    }
                                }
                            }
                        }
                        
                        if let since = state.player.since {
                            self.since = since
                            // start the timer for updating elapsed
                            if self.timerSubscription == nil {
                                self.timerSubscription = self.timerPublisher.sink { _ in
                                    if !self.isScrubbing {
                                        let elapsed = Date().timeIntervalSince(self.since)
                                        self.prettyElapsed = DurationFormatter.shared.format(elapsed)
                                        self.progressPercent = elapsed / Double(self.currentTrackDuration / 1000)
                                    }
                                }
                            }
                        }
                    } else {
                        self.isPlaying = false
                        
                        // cancel the timer for updating elapsed
                        self.timerSubscription?.cancel()
                        self.timerSubscription = nil
                        
                        if let elapsed = state.player.elapsed {
                            self.prettyElapsed = DurationFormatter.shared.format(elapsed)
                        }
                    }
                }.store(in: &cancellables)
        }
        
        func seek(toPercent: Double) {
            let positionMs = Double(self.currentTrackDuration) * toPercent
            Task.init {
                await playerCore.seek(Int(positionMs))
            }
        }
    }
}
