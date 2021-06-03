//
//  TrackProgressSlider.swift
//  Spottie
//
//  Created by Lee Jun Kit on 26/5/21.
//

import SwiftUI

struct TrackProgressSlider: View {
    @ObservedObject var viewModel: TrackProgressSlider.ViewModel
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var prettyProgress: String {
        get {
            let formatter = TrackProgressSlider.DurationFormatter.shared()
            if (self.viewModel.isScrubbing) {
                let scrubbedProgress = self.viewModel.progressPercent * Double(self.viewModel.durationMs)
                return formatter.string(from: scrubbedProgress / 1000.0)!
            } else {
                return formatter.string(from: Double(self.viewModel.progressMs) / 1000.0)!
            }
        }
    }
    
    var prettyDuration: String {
        get {
            return TrackProgressSlider.DurationFormatter.shared().string(from: Double(self.viewModel.durationMs) / 1000.0)!
        }
    }
    
    var body: some View {
        Slider(
            value: $viewModel.progressPercent,
            onEditingChanged: { editing in
                if (!editing) {
                    viewModel.onScrubToNewProgressPercent(viewModel.progressPercent)
                }
                viewModel.isScrubbing = editing
            },
            minimumValueLabel: Text(prettyProgress).foregroundColor(.secondary),
            maximumValueLabel: Text(prettyDuration).foregroundColor(.secondary)
        ) {
            EmptyView()
        }
        .onReceive(timer) { _ in
            viewModel.updateProgress()
        }
    }
}

extension TrackProgressSlider {
    class DurationFormatter {
        private static var sharedDurationFormatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [ .minute, .second ]
            formatter.zeroFormattingBehavior = [ .pad ]
            return formatter
        }()
        
        class func shared() -> DateComponentsFormatter {
            return sharedDurationFormatter
        }
    }
    
    class ViewModel: ObservableObject {
        @Published var isPlaying: Bool
        @Published var progressMs: Int
        @Published var durationMs: Int
        @Published var progressPercent: Double
        var isScrubbing = false
        var onScrubToNewProgressPercent: (_ progressPercent: Double) -> Void
        
        init(isPlaying: Bool, progressMs: Int, durationMs: Int, onScrubToNewProgressPercent: @escaping (_ progressPercent: Double) -> Void) {
            self.isPlaying = isPlaying
            self.progressMs = progressMs
            self.durationMs = durationMs
            self.progressPercent = Double(progressMs) / Double(durationMs)
            self.onScrubToNewProgressPercent = onScrubToNewProgressPercent
        }
        
        func calculateProgressPercent() {
            self.progressPercent = Double(self.progressMs) / Double(self.durationMs)
        }
        
        func updateProgress() {
            if (self.isPlaying) {
                if (self.progressMs < self.durationMs) {
                    self.progressMs += 1000
                    if (!self.isScrubbing) {
                        self.calculateProgressPercent()
                    }
                }
            }
        }
    }
}

struct TrackProgressSlider_Previews: PreviewProvider {
    static let viewModel = TrackProgressSlider.ViewModel(isPlaying: true, progressMs: 20000, durationMs: 120000) { progressPercent in
        
    }
    static var previews: some View {
        TrackProgressSlider(viewModel: viewModel)
    }
}
