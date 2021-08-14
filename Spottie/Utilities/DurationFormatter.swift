//
//  DurationFormatter.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/6/21.
//

import Foundation

class DurationFormatter {
    static let shared = DurationFormatter()
    
    private let formatter: DateComponentsFormatter
    private init() {
        formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
    }
    
    func format(_ from: TimeInterval) -> String {
        return formatter.string(from: from)!
    }
}
