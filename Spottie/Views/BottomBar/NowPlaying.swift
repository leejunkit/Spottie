//
//  NowPlaying.swift
//  Spottie
//
//  Created by Lee Jun Kit on 25/5/21.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct NowPlaying: View {
    class ViewModel: ObservableObject {
        @Published var trackName = ""
        @Published var artistName = ""
        @Published var artworkURL: URL?
        
        @Inject var playerCore: PlayerCore
        @Inject var webAPI: SpotifyWebAPI
        private var cancellables = [AnyCancellable]()
        
        init() {
            playerCore
                .statePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    guard let self = self else { return }
                    guard let state = state else { return }
                    
                    if let trackId = state.player.trackId {
                        Task.init {
                            if case let .success(track) = await self.webAPI.getTrack(trackId) {
                                DispatchQueue.main.async {
                                    self.trackName = track.name
                                    self.artistName = track.artistString
                                    self.artworkURL = track.album.getImageURL(.small)
                                }
                            }
                        }
                    }
                }.store(in: &cancellables)
        }
    }
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        HStack(spacing: 12) {
            WebImage(url: viewModel.artworkURL)
                .resizable()
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.trackName)
                Text(viewModel.artistName)
                    .foregroundColor(.secondary)
            }
            Button(action: {
                print("Like button was tapped")
            }) {
                Image(systemName: "heart")
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct NowPlaying_Previews: PreviewProvider {
    static var previews: some View {
        NowPlaying()
    }
}
