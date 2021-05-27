//
//  PlayPauseButton.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI
import Combine

struct PlayPauseButton<M: PlayerStateProtocol>: View {
    @EnvironmentObject var viewModel: M
    
    var body: some View {
        Button(action: {
            viewModel.onPlayPauseButtonTapped()
        }) {
            Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct PlayPauseButton_Previews: PreviewProvider {
    
    
    static var previews: some View {
        PlayPauseButton<FakePlayerViewModel>()
            .environmentObject(FakePlayerViewModel())
    }
}
