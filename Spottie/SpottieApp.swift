//
//  SpottieApp.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI
import Combine

@main
struct SpottieApp: App {
    init() {
        
    }
    
    @StateObject private var playerViewModel = PlayerViewModel(EventBroker())
    
    var body: some Scene {
        WindowGroup {
            ContentView<PlayerViewModel>()
                .environmentObject(playerViewModel)
        }
        .commands {
            PlayerCommands()
        }
    }
}
