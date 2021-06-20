//
//  ShortcutItem.swift
//  Spottie
//
//  Created by Lee Jun Kit on 19/6/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ShortcutItem: View {
    var itemHeight: CGFloat
    var viewModel: ViewModel
    var onPlayButtonPressed: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack {
            WebImage(url: viewModel.artworkURL)
                .resizable()
                .frame(width: itemHeight, height: itemHeight)
                .aspectRatio(1.0, contentMode: .fill)
            Text(viewModel.title).bold()
                .padding(.leading)
            Spacer()
            GreenPlayButton(
                width: 32,
                onPress: onPlayButtonPressed
            )
            .padding(.trailing)
            .opacity(isHovering ? 1.0 : 0.0)
            .animation(.linear(duration: 0.1))
        }
        .background(
            Color(NSColor.alternatingContentBackgroundColors[1])
                .opacity(isHovering ? 1.0 : 0.3)
                .animation(.linear(duration: 0.1))
        )
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

extension ShortcutItem {
    class ViewModel {
        var title: String
        var artworkURL: URL
        
        init(_ item: RecommendationItem) {
            if let data = item.data {
                switch data {
                case let .album(album):
                    self.title = album.name
                    self.artworkURL = album.getArtworkURL()!
                case let .artist(artist):
                    self.title = artist.name
                    self.artworkURL = URL(string: artist.images[0].url)!
                case let.playlist(playlist):
                    self.title = playlist.name
                    self.artworkURL = URL(string: playlist.images[0].url)!
                case let .link(link):
                    self.title = link.name
                    self.artworkURL = URL(string: link.images[0].url)!
                }
            } else {
                self.title = "Unknown"
                self.artworkURL = URL(string: "https://misc.scdn.co/liked-songs/liked-songs-640.png")!
            }
        }
    }
}

//struct ShortcutItem_Previews: PreviewProvider {
//    static var previews: some View {
//        ShortcutItem(
//            itemHeight: 80,
//            title: "Liked Songs",
//            imageURL: URL(string: "https://misc.scdn.co/liked-songs/liked-songs-640.png")!
//        )
//    }
//}
