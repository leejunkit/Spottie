//
//  CarouselRowItem.swift
//  Spottie
//
//  Created by Lee Jun Kit on 5/6/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct CarouselRowItem: View {
    var vm: ViewModel
    var onPlayButtonPressed: () -> Void
    @ObservedObject private var hoverState = HoverState()
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomTrailing) {
                if vm.artworkIsCircle {
                    WebImage(url: vm.artworkURL)
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fill)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4.0))
                        .shadow(radius: 7)
                } else {
                    WebImage(url: vm.artworkURL)
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fill)
                        .cornerRadius(5)
                }
                GreenPlayButton(width: 48) {
                    onPlayButtonPressed()
                }
                .offset(x: -16, y: -16)
                .opacity(hoverState.isHovering ? 1.0 : 0.0)
                .animation(.linear(duration: 0.1))
            }
            
            Text(vm.title)
                .lineLimit(1)
                .foregroundColor(.primary)
                .font(.headline)
                .padding(.vertical, 4)
            Text(vm.subtitle)
                .lineLimit(2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: 200)
        .padding()
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

extension CarouselRowItem {
    struct ViewModel: Identifiable {
        var id: String
        var title: String
        var subtitle: String
        var artworkURL: URL
        var artworkIsCircle = false
    }
}

//struct CarouselRowItem_Previews: PreviewProvider {
//    static var previews: some View {
//        CarouselRowItem()
//    }
//}
