//
//  SpotifyAPI.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import Foundation
import Combine

enum SpotifyAPI {
    static let client = HTTPClient()
    static let base = URL(string: "http://localhost:24879")!
}

extension SpotifyAPI {
    static func currentPlayerState() -> AnyPublisher<CurrentlyPlayingContextObject?, Error> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase;
        let req = URLRequest(url: base.appendingPathComponent("/web-api/v1/me/player"))
        return client.run(req, decoder).map(\.value).eraseToAnyPublisher()
    }
    
    static func pause() -> AnyPublisher<Nothing?, Error> {
        var req = URLRequest(url: base.appendingPathComponent("/player/pause"))
        req.httpMethod = "POST"
        return client.run(req).map(\.value).eraseToAnyPublisher()
    }
    
    static func resume() -> AnyPublisher<Nothing?, Error> {
        var req = URLRequest(url: base.appendingPathComponent("/player/resume"))
        req.httpMethod = "POST"
        return client.run(req).print().map(\.value).eraseToAnyPublisher()
    }
    
    static func previousTrack() -> AnyPublisher<Nothing?, Error> {
        var req = URLRequest(url: base.appendingPathComponent("/player/prev"))
        req.httpMethod = "POST"
        return client.run(req).print().map(\.value).eraseToAnyPublisher()
    }
    
    static func nextTrack() -> AnyPublisher<Nothing?, Error> {
        var req = URLRequest(url: base.appendingPathComponent("/player/next"))
        req.httpMethod = "POST"
        return client.run(req).print().map(\.value).eraseToAnyPublisher()
    }
}
