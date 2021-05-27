//
//  TrackProgressSlider.swift
//  Spottie
//
//  Created by Lee Jun Kit on 26/5/21.
//

import SwiftUI

struct TrackProgressSlider: View {
    @State var isPlaying = true
    @State var progressMs = 0
    @State var durationMs = 60000
    @State var progressPercent = 0.0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var prettyProgress: String {
        get {
            return TrackProgressSlider.DurationFormatter.shared().string(from: Double(self.progressMs) / 1000.0)!
        }
    }
    
    var prettyDuration: String {
        get {
            return TrackProgressSlider.DurationFormatter.shared().string(from: Double(self.durationMs) / 1000.0)!
        }
    }
    
    var body: some View {
        Slider(
            value: $progressPercent,
            minimumValueLabel: Text(prettyProgress).foregroundColor(.secondary),
            maximumValueLabel: Text(prettyDuration).foregroundColor(.secondary)
        ) {
            Text("")
        }
        .onReceive(timer) { timer in
            if isPlaying {
                if (progressMs < durationMs) {
                    progressMs += 1000
                    progressPercent = Double(self.progressMs) / Double(self.durationMs)
                }
            }
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
}

struct TrackProgressSlider_Previews: PreviewProvider {
    static var previews: some View {
        TrackProgressSlider()
    }
}
