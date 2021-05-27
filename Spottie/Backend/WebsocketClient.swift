//
//  SpotifyState.swift
//  Spottie
//
//  Created by Lee Jun Kit on 22/5/21.
//

import Foundation
import Combine

class WebsocketClient: NSObject, URLSessionWebSocketDelegate {
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
        
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
    }
    
    // MARK: - Receiving events
    func connect() {
        websocketTask.resume()
        listen()
    }
    
    func listen() {
        websocketTask.receive {[weak self] result in
            switch result {
            case .success(let response):
                switch response {
                case .data(_):
                    print("data received")
                case .string(let message):
                    print("string received")
                    print(message)
                @unknown default:
                    print("Unknown default")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
            
            self?.listen()
        }
    }
}
