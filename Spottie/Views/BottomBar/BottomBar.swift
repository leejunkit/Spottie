//
//  BottomBar.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI

struct BottomBar<M: PlayerStateProtocol>: View {
    @EnvironmentObject var viewModel: M
    var body: some View {
        HStack(spacing: 40) {
            NowPlaying(
                trackName: viewModel.trackName,
                artistName: viewModel.artistName,
                artworkURL: viewModel.artworkURL
            )
            .frame(width: 240, alignment: .leading)
            PlayerControls<M>()
            VolumeSlider(
                volumePercent: viewModel.volumePercent,
                onVolumeChanged: viewModel.setVolume
            )
                .frame(width: 160, alignment: .trailing)
        }
    }
}

struct BottomBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomBar<FakePlayerViewModel>()
            .environmentObject(FakePlayerViewModel())
    }
}
