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
    // register dependencies into the container
    @Provider var playerCore = PlayerCore()
    init() {
        DependencyInjector.register(dependency: SpotifyWebAPI(playerCore: playerCore))
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
