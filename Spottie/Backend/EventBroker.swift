//
//  EventBroker.swift
//  Spottie
//
//  Created by Lee Jun Kit on 22/5/21.
//

import Foundation
import Combine

class EventBroker : ObservableObject {
//    private let websocketClient = WebsocketClient(url: URL(string: "ws://localhost:24879/events")!)
    private var cancellables = [AnyCancellable]()
    private let decoder = JSONDecoder()
    
    let onEventReceived = PassthroughSubject<SpotifyEvent, Never>()
    
    init() {
        /*
        websocketClient
            .onMessageReceived
            .receive(on: DispatchQueue.main)
            .print()
            .sink { [weak self] message in
            do {
                guard let self = self else {
                    return;
                }
                let data = message.data(using: .utf8)!
                let event = try self.decoder.decode(SpotifyEvent.self, from: data)
                self.onEventReceived.send(event)
            } catch let error {
                print(error)
            }
        }.store(in: &cancellables)
         */
    }
}
