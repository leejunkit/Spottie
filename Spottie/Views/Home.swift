//
//  Home.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI

struct Home<M: PlayerStateProtocol>: View {
    @EnvironmentObject var viewModel: M
    var body: some View {
        Text("\(viewModel.trackName) by \(viewModel.artistName)")
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home<FakePlayerViewModel>()
            .environmentObject(FakePlayerViewModel())
    }
}
