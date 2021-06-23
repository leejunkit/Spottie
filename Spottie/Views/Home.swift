//
//  Home.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI
import Combine

struct Home: View {
    @ObservedObject var viewModel: ViewModel = ViewModel()
    
    // search
    @State private var searchText = ""
    private var relay = PassthroughSubject<String, Never>()
    private var debouncedPublisher: AnyPublisher<String, Never>
    
    init() {
        self.debouncedPublisher = relay
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var body: some View {
        GeometryReader { reader in
            let numItemsToShow = numberOfItemsToShowInRow(reader)
            
            ScrollView(.vertical) {
                if searchText.isEmpty {
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel.rowViewModels) { vm in
                            if vm.id == "shortcuts" {
                                ShortcutGrid(
                                    items: vm.items,
                                    onItemPressed: viewModel.load
                                )
                                    .padding()
                            } else if vm.items.count > 0 {
                                CarouselRow(
                                    viewModel: vm,
                                    onItemPressed: viewModel.load,
                                    numItemsToShow: numItemsToShow
                                )
                                    .padding()
                            }
                        }
                    }
                } else {
                    Search(
                        viewModel: Search.ViewModel(searchTermPublisher: debouncedPublisher),
                        numItemsPerRow: numItemsToShow
                    )
                }
            }
        }
        .toolbar {
            ToolbarItem {
                SearchField(search: $searchText)
                    .frame(minWidth: 100, idealWidth: 200, maxWidth: .infinity)
            }
        }
        .onChange(of: searchText) { text in
            relay.send(text)
        }
    }
    
    func numberOfItemsToShowInRow(_ reader: GeometryProxy) -> Int {
        let screenPadding = 16
        let itemPadding = 40
        let rowPadding = 16
        let itemWidth = 200
        return (Int(reader.size.width) - (2 * screenPadding) - (2 * rowPadding) - itemPadding) / (itemWidth + itemPadding)
    }
}

extension Home {
    class ViewModel: ObservableObject {
        @Published var rowViewModels: [CarouselRow.ViewModel] = []
        private var cancellables = [AnyCancellable]()
        
        init() {
            SpotifyAPI.getPersonalizedRecommendations().sink { _ in } receiveValue: { response in
                let recommendationGroups = response!.content.items
                self.rowViewModels = recommendationGroups.map { group in
                    if group.id.hasPrefix("podcast") {
                        return CarouselRow.ViewModel(
                            id: group.id,
                            title: group.name,
                            subtitle: group.tagline ?? "",
                            items: []
                        )
                    }
                    
                    let items = group.items.map { item -> CarouselRowItem.ViewModel in
                        let id = item.id
                        var title = ""
                        var subtitle = ""
                        var artworkURL = URL(string: "https://misc.scdn.co/liked-songs/liked-songs-640.png")!
                        var artworkIsCircle = false
                        
                        if let data = item.data {
                            switch data {
                            case let .album(album):
                                title = album.name
                                subtitle = album.artists[0].name
                                artworkURL = album.getArtworkURL()
                            case let .artist(artist):
                                title = artist.name
                                subtitle = "Artist"
                                artworkURL = artist.getArtworkURL()
                                artworkIsCircle = true
                            case let .playlist(playlist):
                                title = playlist.name
                                subtitle = playlist.description ?? ""
                                artworkURL = playlist.getArtworkURL()
                            case let .link(link):
                                title = link.name
                                subtitle = ""
                                artworkURL = URL(string: link.images[0].url)!
                            }
                        }
                        
                        return CarouselRowItem.ViewModel(
                            id: id,
                            title: title,
                            subtitle: subtitle,
                            artworkURL: artworkURL,
                            artworkIsCircle: artworkIsCircle
                        )
                    }
                    
                    let vm = CarouselRow.ViewModel(
                        id: group.id,
                        title: group.name,
                        subtitle: group.tagline ?? "",
                        items: items
                    )
                    
                    return vm
                }
            }.store(in: &cancellables)
        }
        
        func load(_ uri: String) {
            SpotifyAPI.load(uri).sink { _ in } receiveValue: { _ in }.store(in: &cancellables)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .environmentObject(FakePlayerViewModel())
    }
}
