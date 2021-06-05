//
//  RepeatButton.swift
//  Spottie
//
//  Created by Lee Jun Kit on 25/5/21.
//

import SwiftUI

struct RepeatButton: View {
    var repeatMode: RepeatMode
    var onRepeatButtonTapped: () -> Void
    var imageName: String {
        get {
            switch repeatMode {
            case .none:
                return "repeat"
            case .track:
                return "repeat.1"
            case .context:
                return "repeat"
            }
        }
    }
    
    var body: some View {
        Button(action: {
            onRepeatButtonTapped()
        }) {
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: 12, height: 12)
                if repeatMode == .context {
                    Text("ALL")
                        .font(.footnote)
                }
            }

        }
        .buttonStyle(BorderlessButtonStyle())
        .foregroundColor(repeatMode == .none ? .secondary : .green)
    }
}

struct RepeatButton_Previews: PreviewProvider {
    static func onRepeatButtonTapped() {}
    static var previews: some View {
        RepeatButton(repeatMode: .none, onRepeatButtonTapped: onRepeatButtonTapped)
    }
}
