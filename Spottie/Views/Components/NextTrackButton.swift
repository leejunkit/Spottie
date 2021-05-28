//
//  NextTrackButton.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/5/21.
//

import SwiftUI

struct NextTrackButton: View {
    var nextTrackButtonTapped: () -> Void
    var body: some View {
        Button(action: {
            self.nextTrackButtonTapped()
        }) {
            Image(systemName: "forward.end.fill")
                .resizable()
                .frame(width: 12, height: 12)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct NextTrackButton_Previews: PreviewProvider {
    static func nextTrackButtonTapped() {
        print("nextTrackButtonTapped")
    }
    static var previews: some View {
        NextTrackButton(nextTrackButtonTapped: nextTrackButtonTapped)
    }
}
