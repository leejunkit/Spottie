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

struct ContentView: View {
    @State var screen: Screen? = .home
    
    var body: some View {
        NavigationView {
            Sidebar(state: $screen)
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
