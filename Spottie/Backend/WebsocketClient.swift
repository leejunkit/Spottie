//
//  SpotifyState.swift
//  Spottie
//
//  Created by Lee Jun Kit on 22/5/21.
//

import Foundation
import Combine

enum ConnectionState {
    case disconnected
    case connecting
    case connected
}

class WebsocketClient: NSObject, URLSessionWebSocketDelegate {
    let connectionState = CurrentValueSubject<ConnectionState, Never>(.disconnected)
    let onMessageReceived = PassthroughSubject<String, Never>()
    
    var urlSession: URLSession!
    var websocketTask: URLSessionWebSocketTask!
    let delegateQueue = OperationQueue()
    
    init(url: URL) {
        super.init()
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
        websocketTask = urlSession.webSocketTask(with: url)
        connect()
    }
    
    // MARK: - URLSessionWebSocketDelegate
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        connectionState.send(.connected)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        connectionState.send(.disconnected)
    }
    
    // MARK: - Receiving events
    func connect() {
        connectionState.send(.connecting)
        websocketTask.resume()
        listen()
    }
    
    func listen() {
        websocketTask.receive {[weak self] result in
            guard let self = self else {
                return;
            }
            
            switch result {
            case .success(let response):
                switch response {
                case .data(_): break
                case .string(let message):
                    self.onMessageReceived.send(message)
                @unknown default: break
                }
            case .failure(let error):
                print("Error: \(error)")
            }
            
            self.listen()
        }
    }
}
