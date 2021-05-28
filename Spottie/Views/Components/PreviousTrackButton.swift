//
//  PreviousTrackButton.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/5/21.
//

import SwiftUI

struct PreviousTrackButton: View {
    var previousTrackButtonTapped: () -> Void
    var body: some View {
        Button(action: {
            self.previousTrackButtonTapped()
        }) {
            Image(systemName: "backward.end.fill")
                .resizable()
                .frame(width: 12, height: 12)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct PreviousTrackButton_Previews: PreviewProvider {
    static func onPreviousTrackTapped() {
        print("onPreviousTrackTapped")
    }
    static var previews: some View {
        PreviousTrackButton(previousTrackButtonTapped: onPreviousTrackTapped)
    }
}
