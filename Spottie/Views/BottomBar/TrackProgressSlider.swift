//
//  TrackProgressSlider.swift
//  Spottie
//
//  Created by Lee Jun Kit on 26/5/21.
//

import SwiftUI
import Combine

struct TrackProgressSlider: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    
    var prettyProgress: String {
        get {
            if (viewModel.isScrubbing) {
                let scrubbedProgress = viewModel.progressPercent * Double(viewModel.durationMs)
                return DurationFormatter.shared.format(scrubbedProgress / 1000.0)
            } else {
                return DurationFormatter.shared.format(Double(viewModel.progressMs) / 1000.0)
            }
        }
    }
    
    var prettyDuration: String {
        get {
            return DurationFormatter.shared.format(Double(viewModel.durationMs) / 1000.0)
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(prettyProgress).foregroundColor(.secondary)
            }
            .frame(width: 40)
            
            Slider(
                value: $viewModel.progressPercent,
                in: 0...1,
                onEditingChanged: { editing in
                    if (!editing) {
                        viewModel.seek(toPercent: viewModel.progressPercent)
                    }
                    
                    viewModel.isScrubbing = editing
                }
            )
            
            VStack(alignment: .leading) {
                Text(prettyDuration).foregroundColor(.secondary)
            }
            .frame(width: 40)
        }
    }
}

//struct TrackProgressSlider_Previews: PreviewProvider {
//    static let viewModel = TrackProgressSlider.ViewModel(isPlaying: true, progressMs: 20000, durationMs: 120000) { progressPercent in
//
//    }
//    static var previews: some View {
//        TrackProgressSlider(viewModel: viewModel)
//    }
//}
