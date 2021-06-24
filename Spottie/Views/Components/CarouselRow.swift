//
//  CarouselRow.swift
//  Spottie
//
//  Created by Lee Jun Kit on 5/6/21.
//

import SwiftUI

struct CarouselRow: View {
    let viewModel: ViewModel
    let numItemsToShow: Int
    let onItemTapped: (String) -> Void
    let onItemPlayButtonTapped: (String) -> Void
    
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
            
            if viewModel.items.isEmpty {
                HStack {
                    Text("No items to show")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            switch viewModel.type {
            case .grid:
                HStack(alignment: .top, spacing: 40) {
                    ForEach(viewModel.getItemsToShow(requestedNumToShow: numItemsToShow)) { item in
                        CarouselRowItem(
                            vm: item,
                            onPlayButtonPressed: {
                                onItemPlayButtonTapped(item.uri)
                            })
                            .onTapGesture {
                                onItemTapped(item.uri)
                            }
                    }
                }
                .padding([.leading, .trailing])
            case .shortcuts:
                ShortcutGrid(
                    items: viewModel.items,
                    onItemPlayButtonTapped: onItemPlayButtonTapped,
                    onItemTapped: onItemTapped
                )
                .padding([.leading, .trailing])
            case .trackList:
                LazyVStack {
                    ForEach(viewModel.getItemsToShow(requestedNumToShow: 8)) { item in
                        TrackListItem(viewModel: item)
                            .onTapGesture(count: 2) {
                                onItemPlayButtonTapped(item.uri)
                            }
                    }
                }
                .padding([.leading, .trailing])
            }
        }
    }
}

extension CarouselRow {
    enum RowType {
        case shortcuts
        case trackList
        case grid
    }
    
    struct ViewModel: Identifiable {
        var id: String
        var type: RowType
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
