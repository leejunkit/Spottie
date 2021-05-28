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
            return TrackProgressSlider.DurationFormatter.shared().string(from: Double(self.viewModel.progressMs) / 1000.0)!
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
            minimumValueLabel: Text(prettyProgress).foregroundColor(.secondary),
            maximumValueLabel: Text(prettyDuration).foregroundColor(.secondary)
        ) {
            Text("")
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
                
        init(isPlaying: Bool, progressMs: Int, durationMs: Int) {
            self.isPlaying = isPlaying
            self.progressMs = progressMs
            self.durationMs = durationMs
            self.progressPercent = Double(progressMs) / Double(durationMs)
        }
        
        func calculateProgressPercent() {
            self.progressPercent = Double(self.progressMs) / Double(self.durationMs)
        }
        
        func updateProgress() {
            if (self.isPlaying) {
                if (self.progressMs < self.durationMs) {
                    self.progressMs += 1000
                    self.calculateProgressPercent()
                }
            }
        }
    }
}

struct TrackProgressSlider_Previews: PreviewProvider {
    static let viewModel = TrackProgressSlider.ViewModel(isPlaying: true, progressMs: 20000, durationMs: 120000)
    static var previews: some View {
        TrackProgressSlider(viewModel: viewModel)
    }
}
