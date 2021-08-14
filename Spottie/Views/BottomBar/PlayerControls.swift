//
//  PlayerControls.swift
//  Spottie
//
//  Created by Lee Jun Kit on 25/5/21.
//

import SwiftUI

struct PlayerControls<M: PlayerStateProtocol>: View {
    @EnvironmentObject var viewModel: M

    var body: some View {
        VStack {
            HStack(spacing: 28) {
                ShuffleButton(
                    isShuffling: viewModel.isShuffling,
                    toggle: viewModel.toggleShuffle
                )
                PreviousTrackButton(
                    previousTrackButtonTapped: viewModel.previousTrack
                )
                PlayPauseButton(
                    playPauseButtonTapped: viewModel.togglePlayPause,
                    isPlaying: viewModel.isPlaying
                )
                NextTrackButton(
                    nextTrackButtonTapped: viewModel.nextTrack
                )
                RepeatButton(
                    repeatMode: viewModel.repeatMode,
                    onRepeatButtonTapped: viewModel.cycleRepeatMode
                )
            }
            TrackProgressSlider()
                .padding([.leading, .trailing])
        }
    }
}

struct PlayerControls_Previews: PreviewProvider {
    static var previews: some View {
        PlayerControls<FakePlayerViewModel>()
            .environmentObject(FakePlayerViewModel())
    }
}

