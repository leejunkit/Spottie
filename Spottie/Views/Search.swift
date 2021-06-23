//
//  Search.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI
import Combine

struct Search: View {
    @StateObject var viewModel: ViewModel
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                
            }
        }
    }
}

extension Search {
    // The trick to get updates as the NSSearchField is updated
    // is to create a publisher from onChange of searchText
    // https://rhonabwy.com/2021/02/07/integrating-swiftui-bindings-and-combine/
    class ViewModel: ObservableObject {
        @Published var results: SearchResultsResponse?
        
        init(searchTermPublisher: AnyPublisher<String, Never>) {
            searchTermPublisher
                .debounce(for: 0.5, scheduler: DispatchQueue.main)
                .map {
                    SpotifyAPI.search($0)
                        .replaceError(with: nil)
                }
                .switchToLatest()
                .receive(on: DispatchQueue.main)
                
                .assign(to: &$results)
        }
    }
}

struct Search_Previews: PreviewProvider {
    static let vm = Search.ViewModel(searchTermPublisher: Just("Hello").eraseToAnyPublisher())
    static var previews: some View {
        Search(viewModel: vm)
    }
}
