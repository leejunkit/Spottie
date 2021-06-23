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
    let numItemsToShow: Int
    
    var body: some View {
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
                ForEach(viewModel.getItemsToShow(requestedNumToShow: numItemsToShow)) { item in
                    CarouselRowItem(
                        vm: item,
                        onPlayButtonPressed: {
                            onItemPressed(item.id)
                        })
                        .onTapGesture {
                            print("unimplemented")
                        }
                }
            }
            .padding([.leading, .trailing])
        }
        
    }
}

extension CarouselRow {
    struct ViewModel: Identifiable {
        var id: String
        var title: String
        var subtitle: String?
        var items: [CarouselRowItem.ViewModel]
        
        func getItemsToShow(requestedNumToShow: Int) -> [CarouselRowItem.ViewModel] {
            let numItems = items.count
            if (numItems < requestedNumToShow) {
                return items
            } else {
                return Array(items[0...requestedNumToShow - 1])
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
