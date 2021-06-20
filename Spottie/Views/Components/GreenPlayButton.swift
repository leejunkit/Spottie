//
//  GreenPlayButton.swift
//  Spottie
//
//  Created by Lee Jun Kit on 19/6/21.
//

import SwiftUI

struct GreenPlayButton: View {
    var width: CGFloat
    var onPress: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: onPress) {
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: width, height: width)
                .foregroundColor(.green)
                .background(Color.white)
        }
        .buttonStyle(BorderlessButtonStyle())
        .onHover { hovering in
            isHovering = hovering
        }
        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
        .scaleEffect(isHovering ? 1.1 : 1.0)
        .animation(.linear(duration: 0.05))
    }
}

struct GreenPlayButton_Previews: PreviewProvider {
    static var previews: some View {
        GreenPlayButton(width: 32) {
            
        }
    }
}
