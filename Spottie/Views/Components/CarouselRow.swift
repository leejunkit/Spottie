//
//  CarouselRow.swift
//  Spottie
//
//  Created by Lee Jun Kit on 5/6/21.
//

import SwiftUI

struct CarouselRow: View {
    let viewModel: ViewModel
    let onItemPressed: (String) -> Void
    
    var body: some View {
        if viewModel.groupID.hasPrefix("podcast") {
            EmptyView()
        } else {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .font(.title).bold()
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
                        let vm = CarouselRowItem.ViewModel.init(item)
                        CarouselRowItem(viewModel: vm, onPlayButtonPressed: {
                            onItemPressed(item.id)
                        })
                            .onTapGesture {
                                
                            }
                    }
                }
                .padding([.leading, .trailing])
            }
        }
        
    }
}

extension CarouselRow {
    enum RenderMode {
        case circular
        case normal
    }
    
    class ViewModel: ObservableObject {
        var groupID: String
        var title: String
        var subtitle: String?
        var items: [RecommendationItem]
        
        init(_ recommendationGroup: RecommendationGroup, numberOfItemsToShow: Int) {
            self.groupID = recommendationGroup.id
            
            title = recommendationGroup.name
            subtitle = recommendationGroup.tagline
            
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
