//
//  ContentView.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI

enum Screen: Hashable {
   case home, search, library
}

struct ContentView<M: PlayerStateProtocol>: View {
    @State var screen: Screen? = .home
    
    var body: some View {
        VStack {
            NavigationView {
                Sidebar(state: $screen)
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            BottomBar<M>()
                .frame(height: 66)
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView<FakePlayerViewModel>()
            .environmentObject(FakePlayerViewModel())
    }
}
