//
//  LikedSongs.swift
//  LikedSongs
//
//  Created by Lee Jun Kit on 21/8/21.
//

import SwiftUI
import Combine
struct LikedSongs: View {
    class ViewModel: ObservableObject {
        @Published var savedTracks = [WebAPISavedTrackObject]()
        @Published var currentTrackId: String?
        @Inject var webAPI: SpotifyWebAPI
        @Inject var playerCore: PlayerCore
        private var cancellables = [AnyCancellable]()
        
        func load() async {
            webAPI
                .getSavedTracks()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                // TODO: handle error
            }, receiveValue: { tracksChunk in
                self.savedTracks.append(contentsOf: tracksChunk)
            }).store(in: &cancellables)
            
            playerCore
                .statePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    guard let self = self else { return }
                    guard let state = state else { return }
                    self.currentTrackId = state.player.trackId
                }.store(in: &cancellables)
        }
        
        func onRowDoubleClicked(_ row: Int) {
            let ids = savedTracks[row..<savedTracks.count].map { $0.track.id }
            Task.init {
                await playerCore.play(ids)
            }
        }
    }
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        SavedTracksTable(
            currentTrackId: viewModel.currentTrackId,
            data: viewModel.savedTracks,
            onRowDoubleClicked: viewModel.onRowDoubleClicked
        )
        .onAppear {
            Task.init {
                await viewModel.load()
            }
        }
    }
}

struct LikedSongs_Previews: PreviewProvider {
    static var previews: some View {
        LikedSongs()
    }
}
