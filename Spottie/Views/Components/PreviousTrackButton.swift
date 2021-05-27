//
//  PreviousTrackButton.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/5/21.
//

import SwiftUI

struct PreviousTrackButton<M: PlayerStateProtocol>: View {
    @EnvironmentObject var viewModel: M

    var body: some View {
        Button(action: {
            viewModel.onPreviousTrackButtonTapped()
        }) {
            Image(systemName: "backward.end.fill")
                .resizable()
                .frame(width: 12, height: 12)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct PreviousTrackButton_Previews: PreviewProvider {
    static var previews: some View {
        PreviousTrackButton<FakePlayerViewModel>()
            .environmentObject(FakePlayerViewModel())
    }
}
