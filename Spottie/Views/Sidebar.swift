//
//  Sidebar.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI

struct Sidebar: View {
    @Binding var state: Screen?
    
    var body: some View {
        List {
            NavigationLink(
                destination: Home(),
                tag: Screen.home,
                selection: $state,
                label: {
                    Label("Home", systemImage: "house")
                }
            )
            NavigationLink(
                destination: Library(),
                tag: Screen.library,
                selection: $state,
                label: {
                    Label("Library", systemImage: "book")
                }
            )
        }
        .listStyle(SidebarListStyle())
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(state: .constant(.home))
    }
}
