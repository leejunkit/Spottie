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
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(viewModel.results) { vm in
                CarouselRow(viewModel: vm, onItemPressed: { id in
                    
                }, numItemsToShow: numItemsPerRow)
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
                .debounce(for: 0.5, scheduler: DispatchQueue.main)
                .map {
                    SpotifyAPI.search($0)
                        .replaceError(with: nil)
                }
                .switchToLatest()
                .receive(on: DispatchQueue.main)
                .sink { response in
                    if let r = response {
                        let artistsRow = CarouselRow.ViewModel(
                            id: "artists",
                            title: "Artists",
                            subtitle: nil,
                            items: r.artists.items.map { artist in
                                let id = artist.id
                                let title = artist.name
                                let artworkURL = artist.getArtworkURL()
                                return CarouselRowItem.ViewModel(
                                    id: id,
                                    title: title,
                                    subtitle: "Artist",
                                    artworkURL: artworkURL,
                                    artworkIsCircle: true
                                )
                        })
                        
                        let albumsRow = CarouselRow.ViewModel(
                            id: "albums",
                            title: "Albums",
                            subtitle: nil,
                            items: r.albums.items.map { album in
                                let id = album.id
                                let title = album.name
                                let subtitle = album.artists[0].name
                                let artworkURL = album.getArtworkURL()
                                return CarouselRowItem.ViewModel(
                                    id: id,
                                    title: title,
                                    subtitle: subtitle,
                                    artworkURL: artworkURL
                                )
                        })
                        
                        let playlistsRow = CarouselRow.ViewModel(
                            id: "playlists",
                            title: "Playlists",
                            subtitle: nil,
                            items: r.playlists.items.map { playlist in
                                let id = playlist.id
                                let title = playlist.name
                                let subtitle = "\(playlist.tracks.total) tracks, by \(playlist.owner.displayName ?? "an unnamed user")"
                                let artworkURL = playlist.getArtworkURL()
                                return CarouselRowItem.ViewModel(
                                    id: id,
                                    title: title,
                                    subtitle: subtitle,
                                    artworkURL: artworkURL
                                )
                        })
                        
                        self.results = [artistsRow, albumsRow, playlistsRow]
                    }
                }
                .store(in: &cancellables)
        }
    }
}

struct Search_Previews: PreviewProvider {
    static let vm = Search.ViewModel(searchTermPublisher: Just("Hello").eraseToAnyPublisher())
    static var previews: some View {
        Search(viewModel: vm, numItemsPerRow: 4)
    }
}
