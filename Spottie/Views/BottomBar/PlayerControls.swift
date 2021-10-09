//
//  PlayerControls.swift
//  Spottie
//
//  Created by Lee Jun Kit on 25/5/21.
//

import SwiftUI
import Combine

struct PlayerControls: View {
    @StateObject var viewModel = ViewModel()
    var body: some View {
        VStack {
            HStack(spacing: 28) {
                /*
                ShuffleButton(
                    isShuffling: viewModel.isShuffling,
                    toggle: viewModel.toggleShuffle
                )
                */
                PreviousTrackButton(
                    previousTrackButtonTapped: {
                        Task.init {
                            let _ = await viewModel.playerCore.previous()
                        }
                    }
                )
                PlayPauseButton(
                    playPauseButtonTapped: {
                        Task.init {
                            let _ = await viewModel.playerCore.togglePlayback()
                        }
                    },
                    isPlaying: viewModel.isPlaying
                )
                NextTrackButton(
                    nextTrackButtonTapped: {
                        Task.init {
                            let _ = await viewModel.playerCore.next()
                        }
                    }
                )
                /*
                RepeatButton(
                    repeatMode: viewModel.repeatMode,
                    onRepeatButtonTapped: viewModel.cycleRepeatMode
                )
                 */
            }
            TrackProgressSlider()
                .padding([.leading, .trailing])
        }
    }
    
    class ViewModel: ObservableObject {
        @Published var isPlaying = false
        
        @Inject var playerCore: PlayerCore
        private var cancellables = [AnyCancellable]()
        init() {
            playerCore
                .statePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    guard let self = self else { return }
                    guard let state = state else { return }
                    self.isPlaying = state.player.state == .playing
                }.store(in: &cancellables)
        }
    }
}
