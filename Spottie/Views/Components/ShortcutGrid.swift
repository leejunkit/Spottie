//
//  ShortcutsGrid.swift
//  Spottie
//
//  Created by Lee Jun Kit on 18/6/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ShortcutGrid: View {
    let items: [RecommendationItem]
    let onItemPressed: (String) -> Void
    var gridItemLayout = Array(repeating: GridItem(.flexible(), spacing: 20), count: 3)

    var body: some View {
        VStack(alignment: .leading) {
            Text("Good Morning")
                .font(.largeTitle).bold()
                .padding(.leading)
            LazyVGrid(columns: gridItemLayout, spacing: 20) {
                ForEach(items) { item in
                    ShortcutItem(
                        itemHeight: 80,
                        viewModel: ShortcutItem.ViewModel(item),
                        onPlayButtonPressed: {
                            onItemPressed(item.id)
                        }
                    )
                    .frame(height: 80)
                }
            }
            .padding([.leading, .trailing])
        }
        
    }
}

//struct ShortcutsGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        ShortcutGrid()
//    }
//}
