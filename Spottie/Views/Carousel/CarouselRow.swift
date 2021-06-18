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
            viewModel.subtitle.map({
                Text($0)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.leading)
                    .padding(.bottom, 8)
            })
            HStack(alignment: .top, spacing: 40) {
                ForEach(viewModel.items) { item in
                    let vm = CarouselRowItem.ViewModel.init(item, artworkIsCircular: viewModel.renderMode == .circular)
                    CarouselRowItem(viewModel: vm)
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
    enum RenderMode {
        case circular
        case normal
    }
    
    class ViewModel: ObservableObject {
        @Published var renderMode: RenderMode
        @Published var title: String
        @Published var subtitle: String?
        @Published var items: [RecommendationItem]
        let onItemPressed: (String) -> Void
        
        init(_ recommendationGroup: RecommendationGroup, numberOfItemsToShow: Int, onItemPressed: @escaping (String) -> Void) {
            self.onItemPressed = onItemPressed
            
            title = recommendationGroup.name
            subtitle = recommendationGroup.tagline
            
            if (recommendationGroup.id == "home-personalized[favorite-artists]") {
                renderMode = .circular
            } else {
                renderMode = .normal
            }
            
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
