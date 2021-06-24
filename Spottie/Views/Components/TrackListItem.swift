//
//  TrackListItem.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/6/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrackListItem: View {
    let viewModel: CarouselRowItem.ViewModel
    @ObservedObject private var hoverState = HoverState()
    
    var body: some View {
        HStack {
            WebImage(url: viewModel.artworkURL)
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
            VStack(alignment: .leading) {
                Text(viewModel.title)
                viewModel.subtitle.map { subtitle in
                    Text(subtitle)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            viewModel.duration.map {
                Text(DurationFormatter.shared.format(TimeInterval($0)))
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 44)
        .padding([.leading, .trailing])
        .padding([.top, .bottom], 4)
        .background(
            Color(NSColor.alternatingContentBackgroundColors[1])
                .opacity(hoverState.isHovering ? 1.0 : 0.3)
                .animation(.linear(duration: 0.15))
        )
        .onHover { isHovered in
            hoverState.setIsHovering(isHovered)
        }
    }
}

extension TrackListItem {
    class DurationFormatter {
        static let shared = DurationFormatter()
        
        private let formatter: DateComponentsFormatter
        private init() {
            formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .positional
        }
        
        func format(_ from: TimeInterval) -> String {
            return formatter.string(from: from)!
        }
    }
}

struct TrackListItem_Previews: PreviewProvider {
    static let viewModel = CarouselRowItem.ViewModel(
        id: "abc",
        uri: "abc",
        title: "Hello World",
        subtitle: "Artist 1, Artist 2",
        artworkURL: URL(string: "https://misc.scdn.co/liked-songs/liked-songs-640.png")!,
        duration: 240
    )
    static var previews: some View {
        TrackListItem(viewModel: viewModel)
            .frame(height: 44)
    }
}
