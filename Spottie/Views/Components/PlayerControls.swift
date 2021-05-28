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
                ShuffleButton()
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
                RepeatButton()
            }
            TrackProgressSlider(viewModel: TrackProgressSlider.ViewModel(isPlaying: viewModel.isPlaying, progressMs: viewModel.progressMs, durationMs: viewModel.durationMs))
                .padding(.leading)
                .padding(.trailing)
        }
    }
}

struct PlayerControls_Previews: PreviewProvider {
    static var previews: some View {
        PlayerControls<FakePlayerViewModel>()
            .environmentObject(FakePlayerViewModel())
    }
}

