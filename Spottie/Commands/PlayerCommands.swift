//
//  PlayerCommands.swift
//  Spottie
//
//  Created by Lee Jun Kit on 16/6/21.
//

import SwiftUI
import Combine

struct PlayerCommands: Commands {
    struct MenuContent: View {
        private var viewModel: ViewModel = ViewModel()
        var body: some View {
            Button("Toggle Play/Pause") {
                SpotifyAPI.togglePlayPause().sink { _ in } receiveValue: { _ in }.store(in: &viewModel.cancellables)
            }
            .keyboardShortcut(" ", modifiers: [])
        }
    }
    
    var body: some Commands {
        CommandMenu("Player") {
            MenuContent()
        }
    }
}

extension PlayerCommands.MenuContent {
    class ViewModel: ObservableObject {
        var cancellables = [AnyCancellable]()
    }
}
