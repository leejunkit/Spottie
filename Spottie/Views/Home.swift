//
//  Home.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI
import Combine

struct Home: View {
    @ObservedObject var viewModel: ViewModel = ViewModel()
    
    // search
    @State private var searchText = ""
    private var relay = PassthroughSubject<String, Never>()
    private var debouncedPublisher: AnyPublisher<String, Never>
    
    init() {
        self.debouncedPublisher = relay
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var body: some View {
        GeometryReader { reader in
            ScrollView(.vertical) {
                if searchText.isEmpty {
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel.recommendationGroups) { group in
                            if group.id == "shortcuts" {
                                ShortcutGrid(
                                    items: group.items,
                                    onItemPressed: viewModel.load
                                )
                                    .padding()
                            } else if group.items.count > 0 {
                                let vm = CarouselRow.ViewModel.init(group,
                                    numberOfItemsToShow: numberOfItemsToShowInRow(reader)
                                )
                                
                                CarouselRow(
                                    viewModel: vm,
                                    onItemPressed: viewModel.load
                                )
                                    .padding()
                            }
                        }
                    }
                } else {
                    Search(viewModel: Search.ViewModel(searchTermPublisher: debouncedPublisher))
                }
            }
        }
        .toolbar {
            ToolbarItem {
                SearchField(search: $searchText)
                    .frame(minWidth: 100, idealWidth: 200, maxWidth: .infinity)
            }
        }
        .onChange(of: searchText) { text in
            relay.send(text)
        }
    }
    
    func numberOfItemsToShowInRow(_ reader: GeometryProxy) -> Int {
        let screenPadding = 16
        let itemPadding = 40
        let rowPadding = 16
        let itemWidth = 200
        return (Int(reader.size.width) - (2 * screenPadding) - (2 * rowPadding) - itemPadding) / (itemWidth + itemPadding)
    }
}

extension Home {
    class ViewModel: ObservableObject {
        @Published var recommendationGroups: [RecommendationGroup] = []
        private var cancellables = [AnyCancellable]()
        init() {
            SpotifyAPI.getPersonalizedRecommendations().sink { _ in } receiveValue: { response in
                self.recommendationGroups = response!.content.items
            }.store(in: &cancellables)
        }
        
        func load(_ uri: String) {
            SpotifyAPI.load(uri).sink { _ in } receiveValue: { _ in }.store(in: &cancellables)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .environmentObject(FakePlayerViewModel())
    }
}
