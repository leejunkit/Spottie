//
//  PlayPauseButton.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI
import Combine

struct PlayPauseButton: View {
    var playPauseButtonTapped: () -> Void
    var isPlaying: Bool
    
    var body: some View {
        Button(action: {
            playPauseButtonTapped()
        }) {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct PlayPauseButton_Previews: PreviewProvider {
    static func playPauseButtonTapped() {
        print("playPauseButtonTapped")
    }
    
    static var previews: some View {
        PlayPauseButton(
            playPauseButtonTapped: playPauseButtonTapped,
            isPlaying: true
        )
    }
}
