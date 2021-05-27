//
//  PlayerControls.swift
//  Spottie
//
//  Created by Lee Jun Kit on 25/5/21.
//

import SwiftUI

struct PlayerControls<M: PlayerStateProtocol>: View {
    var body: some View {
        VStack {
            HStack(spacing: 28) {
                ShuffleButton()
                PreviousTrackButton<M>()
                PlayPauseButton<M>()
                NextTrackButton<M>()
                RepeatButton()
            }
            TrackProgressSlider()
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

