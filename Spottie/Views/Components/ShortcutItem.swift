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
    var viewModel: CarouselRowItem.ViewModel
    var onPlayButtonPressed: () -> Void
    @ObservedObject private var hoverState = HoverState()
    
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
            .opacity(hoverState.isHovering ? 1.0 : 0.0)
            .animation(.linear(duration: 0.1))
        }
        .background(
            Color(NSColor.alternatingContentBackgroundColors[1])
                .opacity(hoverState.isHovering ? 1.0 : 0.3)
                .animation(.linear(duration: 0.1))
        )
        .onHover { hovering in
            hoverState.setIsHovering(hovering)
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
