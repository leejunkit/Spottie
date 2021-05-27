//
//  NowPlaying.swift
//  Spottie
//
//  Created by Lee Jun Kit on 25/5/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct NowPlaying: View {
    var trackName = ""
    var artistName = ""
    var artworkURL: URL?
    
    var body: some View {
        HStack(spacing: 12) {
            WebImage(url: artworkURL)
                .resizable()
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(trackName)
                Text(artistName)
                    .foregroundColor(.secondary)
            }
            Button(action: {
                print("Like button was tapped")
            }) {
                Image(systemName: "heart")
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct NowPlaying_Previews: PreviewProvider {
    static var previews: some View {
        NowPlaying()
    }
}
