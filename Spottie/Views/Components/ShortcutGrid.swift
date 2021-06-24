//
//  ShortcutsGrid.swift
//  Spottie
//
//  Created by Lee Jun Kit on 18/6/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ShortcutGrid: View {
    let items: [CarouselRowItem.ViewModel]
    let onItemPlayButtonTapped: (String) -> Void
    let onItemTapped: (String) -> Void
    var gridItemLayout = Array(repeating: GridItem(.flexible(), spacing: 20), count: 3)

    var body: some View {
        LazyVGrid(columns: gridItemLayout, spacing: 20) {
            ForEach(items) { item in
                ShortcutItem(
                    itemHeight: 80,
                    viewModel: item,
                    onPlayButtonPressed: {
                        onItemPlayButtonTapped(item.uri)
                    }
                )
                .frame(height: 80)
                .onTapGesture {
                    onItemTapped(item.uri)
                }
            }
        }
    }
}

//struct ShortcutsGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        ShortcutGrid()
//    }
//}
