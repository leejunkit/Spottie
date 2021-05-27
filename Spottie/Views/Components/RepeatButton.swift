//
//  RepeatButton.swift
//  Spottie
//
//  Created by Lee Jun Kit on 25/5/21.
//

import SwiftUI

struct RepeatButton: View {
    var body: some View {
        Button(action: {
        }) {
            Image(systemName: "repeat")
                .resizable()
                .frame(width: 12, height: 12)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct RepeatButton_Previews: PreviewProvider {
    static var previews: some View {
        RepeatButton()
    }
}
