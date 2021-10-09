//
//  Home.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI
import Combine

struct Home: View {
    @ObservedObject var viewModel = ViewModel()
    
    // search
    @State private var searchText = ""
    private var relay = PassthroughSubject<String, Never>()
    private var debouncedPublisher: AnyPublisher<String, Never>
    
    init() {
        self.debouncedPublisher = relay
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func onItemTapped(id: String) -> Void {
        
    }
    
    func onItemPlayButtonTapped(id: String) -> Void {
        viewModel.load(id)
    }
    
    var body: some View {
        GeometryReader { reader in
            let numItemsToShow = numberOfItemsToShowInRow(reader)
            
            ScrollView(.vertical) {
                if searchText.isEmpty {
                    LazyVStack(alignment: .leading) {
                        Text("Good Morning")
                            .font(.largeTitle).bold()
                            .padding(.leading)
                        ForEach(viewModel.rowViewModels) { vm in
                            if !vm.items.isEmpty {
                                CarouselRow(
                                    viewModel: vm,
                                    numItemsToShow: numItemsToShow,
                                    onItemTapped: onItemTapped,
                                    onItemPlayButtonTapped: onItemPlayButtonTapped
                                )
                                .padding()
                            }
                        }
                    }
                } else {
                    Search(
                        viewModel: Search.ViewModel(searchTermPublisher: debouncedPublisher),
                        numItemsPerRow: numItemsToShow,
                        onItemTapped: onItemTapped,
                        onItemPlayButtonTapped: onItemPlayButtonTapped
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
        @Inject var webAPI: SpotifyWebAPI
        @Published var rowViewModels: [CarouselRow.ViewModel] = []
        private var cancellables = [AnyCancellable]()
        
        init() {
            // TODO: fix broken API call here for personalized recommendations
            
            Task.init {
                let result = await webAPI.getPersonalizedRecommendations()
                guard case let .success(response) = result else {
                    // TODO: handle errors here
                    return
                }
                
                let recommendationGroups = response.content.items
                self.rowViewModels = recommendationGroups.map { group in
                    if group.id.hasPrefix("podcast") {
                        return CarouselRow.ViewModel(
                            id: group.id,
                            type: .grid,
                            title: group.name,
                            subtitle: group.tagline ?? "",
                            items: []
                        )
                    }
                    
                    let items = group.items.map { item -> CarouselRowItem.ViewModel in
                        let id = item.id
                        var uri = ""
                        var title = ""
                        var subtitle = ""
                        var artworkURL = URL(string: "https://misc.scdn.co/liked-songs/liked-songs-640.png")!
                        var artworkIsCircle = false
                        
                        if let data = item.data {
                            switch data {
                            case let .album(album):
                                uri = album.uri
                                title = album.name
                                subtitle = album.artists.map({$0.name}).joined(separator: ", ")
                                artworkURL = album.getImageURL(.large)
                            case let .artist(artist):
                                uri = artist.uri
                                title = artist.name
                                subtitle = "Artist"
                                artworkURL = artist.getImageURL(.large)
                                artworkIsCircle = true
                            case let .playlist(playlist):
                                uri = playlist.uri
                                title = playlist.name
                                subtitle = playlist.description ?? "\(playlist.tracks.total) tracks, by \(playlist.owner.displayName ?? "an unnamed user")"
                                artworkURL = playlist.getImageURL(.large)
                            case let .link(link):
                                title = link.name
                                subtitle = ""
                                artworkURL = URL(string: link.images[0].url)!
                            }
                        }
                        
                        return CarouselRowItem.ViewModel(
                            id: id,
                            uri: uri,
                            title: title,
                            subtitle: subtitle,
                            artworkURL: artworkURL,
                            artworkIsCircle: artworkIsCircle
                        )
                    }
                    
                    let vm = CarouselRow.ViewModel(
                        id: group.id,
                        type: group.id == "shortcuts" ? .shortcuts : .grid,
                        title: group.name,
                        subtitle: group.tagline ?? "",
                        items: items
                    )
                    
                    return vm
                }
            }
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
