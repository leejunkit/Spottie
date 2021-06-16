//
//  CarouselRow.swift
//  Spottie
//
//  Created by Lee Jun Kit on 5/6/21.
//

import SwiftUI

struct CarouselRow: View {
    var viewModel: ViewModel
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.title)
                .font(.title)
                .padding(.leading)
            Text(viewModel.subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.leading)
                .padding(.bottom, 8)
            HStack(alignment: .top, spacing: 40) {
                ForEach(viewModel.items) { item in
                    CarouselRowItem(viewModel: CarouselRowItem.ViewModel.init(item))
                        .onTapGesture {
                            viewModel.onItemPressed(item.id)
                        }
                }
            }
            .padding([.leading, .trailing])
        }
    }
}

extension CarouselRow {
    class ViewModel: ObservableObject {
        @Published var title: String
        @Published var subtitle = "Unwind with these calming playlists."
        @Published var items: [RecommendationItem]
        let onItemPressed: (String) -> Void
        
        init(_ recommendationGroup: RecommendationGroup, numberOfItemsToShow: Int, onItemPressed: @escaping (String) -> Void) {
            self.onItemPressed = onItemPressed
            
            title = recommendationGroup.name
            
            let numItems = recommendationGroup.items.count
            if (numItems < numberOfItemsToShow) {
                items = recommendationGroup.items
            } else {
                items = Array(recommendationGroup.items[0...numberOfItemsToShow - 1])
            }
        }
    }
}

//struct CarouselRow_Previews: PreviewProvider {
////    static let group = RecommendationGroup()
////    static var previews: some View {
////        CarouselRow(viewModel: <#T##CarouselRow.ViewModel#>.init())
////    }
//}
