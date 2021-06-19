//
//  CarouselRowItem.swift
//  Spottie
//
//  Created by Lee Jun Kit on 5/6/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct CarouselRowItem: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.artworkIsCircle {
                WebImage(url: viewModel.artworkURL)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fill)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4.0))
                    .shadow(radius: 7)
            } else {
                WebImage(url: viewModel.artworkURL)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fill)
                    .cornerRadius(5)
            }
            Text(viewModel.title)
                .lineLimit(1)
                .foregroundColor(.primary)
                .font(.headline)
                .padding(.vertical, 4)
            Text(viewModel.subtitle)
                .lineLimit(2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: 200)
        .padding()
        .background(
            Color(NSColor.alternatingContentBackgroundColors[1])
                .opacity(viewModel.isHovering ? 1.0 : 0.3)
        )
        .onHover { isHovered in
            viewModel.isHovering = isHovered
        }
    }
}

extension CarouselRowItem {
    class ViewModel: ObservableObject {
        @Published var title: String
        @Published var subtitle: String
        @Published var artworkURL: URL
        @Published var isHovering = false
        @Published var artworkIsCircle = false
        
        init(_ item: RecommendationItem) {
            if let data = item.data {
                switch data {
                case let .album(album):
                    self.title = album.name
                    self.subtitle = album.artists[0].name
                    self.artworkURL = album.getArtworkURL()!
                case let .artist(artist):
                    self.title = artist.name
                    self.subtitle = "Artist"
                    self.artworkURL = URL(string: artist.images[0].url)!
                    self.artworkIsCircle = true
                case let.playlist(playlist):
                    self.title = playlist.name
                    self.subtitle = playlist.description ?? ""
                    self.artworkURL = URL(string: playlist.images[0].url)!
                default:
                    self.title = ""
                    self.subtitle = ""
                    self.artworkURL = URL(string: "https://misc.scdn.co/liked-songs/liked-songs-640.png")!
                }
            } else {
                self.title = ""
                self.subtitle = ""
                self.artworkURL = URL(string: "https://misc.scdn.co/liked-songs/liked-songs-640.png")!
            }
        }
    }
}

//struct CarouselRowItem_Previews: PreviewProvider {
//    static var previews: some View {
//        CarouselRowItem()
//    }
//}
