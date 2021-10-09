//
//  PlayerCommands.swift
//  Spottie
//
//  Created by Lee Jun Kit on 16/6/21.
//

import SwiftUI
import Combine

struct PlayerCommands: Commands {
    @Inject var playerCore: PlayerCore
    @Inject var webAPI: SpotifyWebAPI
    
    var body: some Commands {
        CommandMenu("Player") {
            Button("Toggle Playback") {
                Task.init {
                    await playerCore.togglePlayback()
                }
            }
            .keyboardShortcut(" ", modifiers: [])
        }
    }
}
