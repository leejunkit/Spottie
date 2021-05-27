//
//  ShuffleButton.swift
//  Spottie
//
//  Created by Lee Jun Kit on 25/5/21.
//

import SwiftUI

struct ShuffleButton: View {
    var body: some View {
        Button(action: {
        }) {
            Image(systemName: "shuffle")
                .resizable()
                .frame(width: 12, height: 12)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct ShuffleButton_Previews: PreviewProvider {
    static var previews: some View {
        ShuffleButton()
    }
}
