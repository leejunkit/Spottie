//
//  PlaylistDetail.swift
//  PlaylistDetail
//
//  Created by Lee Jun Kit on 22/9/21.
//

import SwiftUI
import Combine

struct PlaylistDetail: View {
    class ViewModel: ObservableObject {
        @Published var playlist: WebAPISimplifiedPlaylistObject
        @Published var tracks = [WebAPISavedTrackObject]()
        @Published var currentTrackId: String?

        @Inject var webAPI: SpotifyWebAPI
        @Inject var playerCore: PlayerCore
        
        private var cancellables = [AnyCancellable]()

        init(_ playlist: WebAPISimplifiedPlaylistObject) {
            self.playlist = playlist
        }
        
        func load() {
            let endpoint = URL(string: playlist.tracks.href)!
            let subject = PassthroughSubject<[WebAPISavedTrackObject], WebAPIError>()
            
            Task.init {
                await webAPI.sendItemsToSubjectFromPagedEndpoint(
                    type: WebAPISavedTrackObject.self,
                    endpoint: endpoint,
                    subject: subject
                )
            }
            
            subject.receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
                // TODO: handle error
            }, receiveValue: { [weak self] tracksChunk in
                self?.tracks.append(contentsOf: tracksChunk)
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
            let ids = tracks[row..<tracks.count].map { $0.track.id }
            Task.init {
                await playerCore.play(ids)
            }
        }
    }
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        SavedTracksTable(
            currentTrackId: viewModel.currentTrackId,
            data: viewModel.tracks,
            onRowDoubleClicked: viewModel.onRowDoubleClicked
        )
        .onAppear {
            viewModel.load()
        }
    }
}
