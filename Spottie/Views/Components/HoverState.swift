//
//  HoverState.swift
//  Spottie
//
//  Created by Lee Jun Kit on 23/6/21.
//

import SwiftUI

class HoverState: ObservableObject {
    @Published var isHovering = false
    func setIsHovering(_ isHovering: Bool) {
        self.isHovering = isHovering
    }
}
