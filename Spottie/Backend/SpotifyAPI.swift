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
    
    static func seek(posMs: Int) -> AnyPublisher<Nothing?, Error> {
        let queryItems = [URLQueryItem(name: "pos", value: "\(posMs)")]
        var urlComponents = URLComponents(url: base.appendingPathComponent("/player/seek"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems

        var req = URLRequest(url: urlComponents.url!)
        req.httpMethod = "POST"
        return client.run(req).print().map(\.value).eraseToAnyPublisher()
    }
    
    static func setVolume(volumePercent: Float) -> AnyPublisher<Nothing?, Error> {
        let rawVolume = Int(volumePercent * 65535)
        let queryItems = [URLQueryItem(name: "volume", value: "\(rawVolume)")]
        var urlComponents = URLComponents(url: base.appendingPathComponent("/player/set-volume"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems

        var req = URLRequest(url: urlComponents.url!)
        req.httpMethod = "POST"
        return client.run(req).print().map(\.value).eraseToAnyPublisher()
    }
    
    static func setShuffle(shuffle: Bool) -> AnyPublisher<Nothing?, Error> {
        let queryItems = [URLQueryItem(name: "val", value: shuffle ? "true" : "false")]
        var urlComponents = URLComponents(url: base.appendingPathComponent("/player/shuffle"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems

        var req = URLRequest(url: urlComponents.url!)
        req.httpMethod = "POST"
        return client.run(req).print().map(\.value).eraseToAnyPublisher()
    }
    
    static func setRepeatMode(mode: RepeatMode) -> AnyPublisher<Nothing?, Error> {
        let queryItems = [URLQueryItem(name: "val", value: mode.rawValue)]
        var urlComponents = URLComponents(url: base.appendingPathComponent("/player/repeat"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems

        var req = URLRequest(url: urlComponents.url!)
        req.httpMethod = "POST"
        return client.run(req).print().map(\.value).eraseToAnyPublisher()
    }
}
