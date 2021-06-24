//
//  Search.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI
import Combine

struct Search: View {
    @StateObject var viewModel: ViewModel
    var numItemsPerRow: Int
    let onItemTapped: (String) -> Void
    let onItemPlayButtonTapped: (String) -> Void
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(viewModel.results) { vm in
                CarouselRow(
                    viewModel: vm,
                    numItemsToShow: numItemsPerRow,
                    onItemTapped: onItemTapped,
                    onItemPlayButtonTapped: onItemPlayButtonTapped
                )
            }
        }
    }
}

extension Search {
    // The trick to get updates as the NSSearchField is updated
    // is to create a publisher from onChange of searchText
    // https://rhonabwy.com/2021/02/07/integrating-swiftui-bindings-and-combine/
    class ViewModel: ObservableObject {
        @Published var results: [CarouselRow.ViewModel] = []
        private var cancellables = [AnyCancellable]()
        
        init(searchTermPublisher: AnyPublisher<String, Never>) {
            searchTermPublisher
                .debounce(for: 0.3, scheduler: DispatchQueue.main)
                .map {
                    SpotifyAPI.search($0)
                        .replaceError(with: nil)
                }
                .switchToLatest()
                .receive(on: DispatchQueue.main)
                .sink { response in
                    if let r = response {
                        let tracksRow = CarouselRow.ViewModel(
                            id: "tracks",
                            type: .trackList,
                            title: "Tracks",
                            subtitle: nil,
                            items: r.tracks.items.map { track in
                                let id = track.id
                                let title = track.name
                                let subtitle = track.artists.map({$0.name}).joined(separator: ", ")
                                let artworkURL = track.album.getImageURL(.small)
                                return CarouselRowItem.ViewModel(
                                    id: id,
                                    uri: track.uri,
                                    title: title,
                                    subtitle: subtitle,
                                    artworkURL: artworkURL,
                                    duration: track.durationMs / 1000
                                )
                        })
                        
                        let artistsRow = CarouselRow.ViewModel(
                            id: "artists",
                            type: .grid,
                            title: "Artists",
                            subtitle: nil,
                            items: r.artists.items.map { artist in
                                let id = artist.id
                                let title = artist.name
                                let artworkURL = artist.getImageURL(.large)
                                return CarouselRowItem.ViewModel(
                                    id: id,
                                    uri: artist.uri,
                                    title: title,
                                    subtitle: "Artist",
                                    artworkURL: artworkURL,
                                    artworkIsCircle: true
                                )
                        })
                        
                        let albumsRow = CarouselRow.ViewModel(
                            id: "albums",
                            type: .grid,
                            title: "Albums",
                            subtitle: nil,
                            items: r.albums.items.map { album in
                                let id = album.id
                                let title = album.name
                                let subtitle = album.artists.map({$0.name}).joined(separator: ", ")
                                let artworkURL = album.getImageURL(.large)
                                return CarouselRowItem.ViewModel(
                                    id: id,
                                    uri: album.uri,
                                    title: title,
                                    subtitle: subtitle,
                                    artworkURL: artworkURL
                                )
                        })
                        
                        let playlistsRow = CarouselRow.ViewModel(
                            id: "playlists",
                            type: .grid,
                            title: "Playlists",
                            subtitle: nil,
                            items: r.playlists.items.map { playlist in
                                let id = playlist.id
                                let title = playlist.name
                                let subtitle = "\(playlist.tracks.total) tracks, by \(playlist.owner.displayName ?? "an unnamed user")"
                                let artworkURL = playlist.getImageURL(.large)
                                return CarouselRowItem.ViewModel(
                                    id: id,
                                    uri: playlist.uri,
                                    title: title,
                                    subtitle: subtitle,
                                    artworkURL: artworkURL
                                )
                        })
                        
                        self.results = [tracksRow, artistsRow, albumsRow, playlistsRow]
                    }
                }
                .store(in: &cancellables)
        }
    }
}

struct Search_Previews: PreviewProvider {
    static let vm = Search.ViewModel(searchTermPublisher: Just("Hello").eraseToAnyPublisher())
    static var previews: some View {
        Search(
            viewModel: vm,
            numItemsPerRow: 4,
            onItemTapped: { id in },
            onItemPlayButtonTapped: { id in }
        )
    }
}
