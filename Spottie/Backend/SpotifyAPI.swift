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
    
    static func load(_ uri: String) -> AnyPublisher<Nothing?, Error> {
        let queryItems = [
            URLQueryItem(name: "uri", value: uri),
            URLQueryItem(name: "play", value: "true")
        ]
        var urlComponents = URLComponents(url: base.appendingPathComponent("/player/load"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems

        var req = URLRequest(url: urlComponents.url!)
        req.httpMethod = "POST"
        return client.run(req).map(\.value).eraseToAnyPublisher()
    }
    
    static func togglePlayPause() -> AnyPublisher<Nothing?, Error> {
        var req = URLRequest(url: base.appendingPathComponent("/player/play-pause"))
        req.httpMethod = "POST"
        return client.run(req).map(\.value).eraseToAnyPublisher()
    }
    
    static func pause() -> AnyPublisher<Nothing?, Error> {
        var req = URLRequest(url: base.appendingPathComponent("/player/pause"))
        req.httpMethod = "POST"
        return client.run(req).map(\.value).eraseToAnyPublisher()
    }
    
    static func resume() -> AnyPublisher<Nothing?, Error> {
        var req = URLRequest(url: base.appendingPathComponent("/player/resume"))
        req.httpMethod = "POST"
        return client.run(req).map(\.value).eraseToAnyPublisher()
    }
    
    static func previousTrack() -> AnyPublisher<Nothing?, Error> {
        var req = URLRequest(url: base.appendingPathComponent("/player/prev"))
        req.httpMethod = "POST"
        return client.run(req).map(\.value).eraseToAnyPublisher()
    }
    
    static func nextTrack() -> AnyPublisher<Nothing?, Error> {
        var req = URLRequest(url: base.appendingPathComponent("/player/next"))
        req.httpMethod = "POST"
        return client.run(req).map(\.value).eraseToAnyPublisher()
    }
    
    static func seek(posMs: Int) -> AnyPublisher<Nothing?, Error> {
        let queryItems = [URLQueryItem(name: "pos", value: "\(posMs)")]
        var urlComponents = URLComponents(url: base.appendingPathComponent("/player/seek"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems

        var req = URLRequest(url: urlComponents.url!)
        req.httpMethod = "POST"
        return client.run(req).map(\.value).eraseToAnyPublisher()
    }
    
    static func setVolume(volumePercent: Float) -> AnyPublisher<Nothing?, Error> {
        let rawVolume = Int(volumePercent * 65535)
        let queryItems = [URLQueryItem(name: "volume", value: "\(rawVolume)")]
        var urlComponents = URLComponents(url: base.appendingPathComponent("/player/set-volume"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems

        var req = URLRequest(url: urlComponents.url!)
        req.httpMethod = "POST"
        return client.run(req).map(\.value).eraseToAnyPublisher()
    }
    
    static func setShuffle(shuffle: Bool) -> AnyPublisher<Nothing?, Error> {
        let queryItems = [URLQueryItem(name: "val", value: shuffle ? "true" : "false")]
        var urlComponents = URLComponents(url: base.appendingPathComponent("/player/shuffle"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems

        var req = URLRequest(url: urlComponents.url!)
        req.httpMethod = "POST"
        return client.run(req).map(\.value).eraseToAnyPublisher()
    }
    
    static func setRepeatMode(mode: RepeatMode) -> AnyPublisher<Nothing?, Error> {
        let queryItems = [URLQueryItem(name: "val", value: mode.rawValue)]
        var urlComponents = URLComponents(url: base.appendingPathComponent("/player/repeat"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems

        var req = URLRequest(url: urlComponents.url!)
        req.httpMethod = "POST"
        return client.run(req).map(\.value).eraseToAnyPublisher()
    }
    
    static func getPersonalizedRecommendations() -> AnyPublisher<RecommendationsResponse?, Error> {
        // get the current date
        let date = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        
        let queryItems = [
            URLQueryItem(name: "timestamp", value: formatter.string(from: date)),
            URLQueryItem(name: "platform", value: "web"),
            URLQueryItem(name: "content_limit", value: "10"),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "types", value: "album,playlist,artist,show,station,episode"),
            URLQueryItem(name: "image_style", value: "gradient_overlay"),
            URLQueryItem(name: "country", value: "SG"),
            URLQueryItem(name: "locale", value: "en"),
            URLQueryItem(name: "market", value: "from_token")
        ]
        
        var urlComponents = URLComponents(
            url: base.appendingPathComponent("/web-api/v1/views/personalized-recommendations"),
            resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems

        var req = URLRequest(url: urlComponents.url!)
        req.httpMethod = "GET"
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase;
        
        return client.run(req, decoder).map(\.value).eraseToAnyPublisher()
    }
    
    static func search(_ term: String) -> AnyPublisher<SearchResultsResponse?, Error> {
        let queryItems = [
            URLQueryItem(name: "q", value: term),
            URLQueryItem(name: "type", value: "album,artist,playlist,track"),
            URLQueryItem(name: "market", value: "from_token")
        ]
        
        var urlComponents = URLComponents(
            url: URL(string: "https://api.spotify.com/v1/search")!,
            resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems
        
        var req = URLRequest(url: urlComponents.url!)
        req.httpMethod = "GET"
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase;
        
        // librespot-java web-api proxy has a bug where it doubly-percent encodes
        // so we grab the token and perform the search ourselves
        return
            token("user-read-private")
            .flatMap { tokenObj -> AnyPublisher<HTTPClient.Response<SearchResultsResponse?>, Error> in
                let token = tokenObj!.token
                req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                return client.run(req, decoder)
            }
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    static func token(_ scopes: String) -> AnyPublisher<TokenObject?, Error> {
        var req = URLRequest(url: base.appendingPathComponent("/token/\(scopes)"))
        req.httpMethod = "POST"
        return client.run(req).print().map(\.value).eraseToAnyPublisher()
    }
}
