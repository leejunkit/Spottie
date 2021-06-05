//
//  VolumeSlider.swift
//  Spottie
//
//  Created by Lee Jun Kit on 3/6/21.
//

import SwiftUI

struct VolumeSlider: View {
    var volumePercent: Float
    var onVolumeChanged: (Float) -> Void
    
    var imageName: String {
        get {
            if (volumePercent > 0.8) {
                return "speaker.wave.3.fill"
            } else if (volumePercent > 0.5) {
                return "speaker.wave.2.fill"
            } else if (volumePercent > 0.3) {
                return "speaker.wave.1.fill"
            } else {
                return "speaker.fill"
            }
        }
    }
    
    var body: some View {
        Slider(value: Binding(get: {
            self.volumePercent
        }, set: { newVolumePercent in
            self.onVolumeChanged(newVolumePercent)
        }), in: 0...1) {
            VStack(alignment: .trailing) {
                Image(systemName: imageName)
                    .foregroundColor(.secondary)
            }
            .frame(width: 26, height: 26)
        }
    }
}

struct VolumeSlider_Previews: PreviewProvider {
    static func onVolumeChanged(volumePercent: Float) {
        print("new volume: \(volumePercent)")
    }
    
    static var previews: some View {
        VolumeSlider(volumePercent: Float(0.5), onVolumeChanged: onVolumeChanged)
    }
}
