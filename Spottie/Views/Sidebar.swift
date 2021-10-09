//
//  Sidebar.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI
import Combine

struct Sidebar: View {
    class ViewModel: ObservableObject {
        @Published var playlists = [WebAPISimplifiedPlaylistObject]()

        @Inject var webAPI: SpotifyWebAPI
        @Inject var playerCore: PlayerCore
        private var cancellables = [AnyCancellable]()
        
        func load() {
            webAPI
                .getLibraryPlaylists()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                // TODO: handle error
            }, receiveValue: { playlistsChunk in
                self.playlists.append(contentsOf: playlistsChunk)
            }).store(in: &cancellables)
        }
    }
    
    @StateObject var viewModel = ViewModel()
    @Binding var state: Screen?
    
    var body: some View {
        List {
            Group {
                NavigationLink(
                    destination: Home(),
                    tag: Screen.home,
                    selection: $state,
                    label: {
                        Label("Home", systemImage: "house")
                    }
                )
                NavigationLink(
                    destination: Library(),
                    tag: Screen.library,
                    selection: $state,
                    label: {
                        Label("Browse", systemImage: "book")
                    }
                )
                NavigationLink(
                    destination: Library(),
                    tag: Screen.library,
                    selection: $state,
                    label: {
                        Label("Play Queue", systemImage: "book")
                    }
                )
            }
            
            Spacer()
            Text("Library")
            Group {
                NavigationLink(destination: LikedSongs()) {
                    Label("Liked Songs", systemImage: "option")
                }
                NavigationLink(destination: Library()) {
                    Label("Artists", systemImage: "slider.horizontal.3")
                }
                NavigationLink(destination: Library()) {
                    Label("Albums", systemImage: "slider.horizontal.3")
                }
                NavigationLink(destination: Library()) {
                    Label("Podcasts", systemImage: "slider.horizontal.3")
                }
            }
            
            Divider()
            Group {
                ForEach(viewModel.playlists) { playlist in
                    NavigationLink(destination: PlaylistDetail(viewModel: PlaylistDetail.ViewModel(playlist))) {
                        Label(playlist.name, systemImage: "").labelStyle(TitleOnlyLabelStyle())
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.load()
            }
        }
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(state: .constant(.home))
    }
}
