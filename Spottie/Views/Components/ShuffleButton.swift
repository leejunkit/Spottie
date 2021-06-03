//
//  ShuffleButton.swift
//  Spottie
//
//  Created by Lee Jun Kit on 25/5/21.
//

import SwiftUI

struct ShuffleButton: View {
    var isShuffling: Bool
    var toggle: () -> Void
    
    var body: some View {
        Button(action: {
            toggle()
        }) {
            Image(systemName: "shuffle")
                .resizable()
                .frame(width: 12, height: 12)
        }
        .buttonStyle(BorderlessButtonStyle())
        .foregroundColor(isShuffling ? .green : .secondary)
    }
}

struct ShuffleButton_Previews: PreviewProvider {
    static func toggle() {}
    static var previews: some View {
        ShuffleButton(isShuffling: false, toggle: toggle)
    }
}
