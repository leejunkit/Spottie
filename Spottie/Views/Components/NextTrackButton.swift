//
//  NextTrackButton.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/5/21.
//

import SwiftUI

struct NextTrackButton<M: PlayerStateProtocol>: View {
    @EnvironmentObject var viewModel: M

    var body: some View {
        Button(action: {
            viewModel.onNextTrackButtonTapped()
        }) {
            Image(systemName: "forward.end.fill")
                .resizable()
                .frame(width: 12, height: 12)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct NextTrackButton_Previews: PreviewProvider {
    static var previews: some View {
        NextTrackButton<FakePlayerViewModel>()
            .environmentObject(FakePlayerViewModel())
    }
}
