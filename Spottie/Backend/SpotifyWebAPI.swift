//
//  SpotifyWebAPI.swift
//  SpotifyWebAPI
//
//  Created by Lee Jun Kit on 21/8/21.
//

import Foundation
import Combine

enum WebAPIError: Error {
    case unknown
    case authTokenError(CurlError)
    case decodingError(Error)
}

actor TrackCache {
    var cachedTracks = [String: WebAPITrackObject]()
    func get(_ id: String) -> WebAPITrackObject? {
        return cachedTracks[id]
    }
    
    func set(tracks: [WebAPITrackObject]) {
        for track in tracks {
            cachedTracks[track.id] = track
        }
    }
}

struct SpotifyWebAPI {
    let playerCore: PlayerCore
    let trackCache = TrackCache()
    let decoder = JSONDecoder()
    
    init(playerCore: PlayerCore) {
        self.playerCore = playerCore
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func getTrack(_ id: String) async -> Result<WebAPITrackObject, WebAPIError> {
        if let track = await trackCache.get(id) {
            return .success(track)
        }
        
        let url = "https://api.spotify.com/v1/tracks/\(id)"
        var req = URLRequest(url: URL(string: url)!)
        req = await addAuthorizationHeader(request: &req)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let track = try decoder.decode(WebAPITrackObject.self, from: data)
            await trackCache.set(tracks: [track])
            return .success(track)
        } catch {
            return .failure(.unknown)
        }
    }
    
    func getSavedTracks() -> AnyPublisher<[WebAPISavedTrackObject], WebAPIError> {
        let subject = PassthroughSubject<[WebAPISavedTrackObject], WebAPIError>()
        let endpoint = URL(string: "https://api.spotify.com/v1/me/tracks?limit=50&offset=0")!
        Task.init {
            await sendItemsToSubjectFromPagedEndpoint(
                type: WebAPISavedTrackObject.self,
                endpoint: endpoint,
                subject: subject
            )
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func getLibraryPlaylists() -> AnyPublisher<[WebAPISimplifiedPlaylistObject], WebAPIError> {
        let subject = PassthroughSubject<[WebAPISimplifiedPlaylistObject], WebAPIError>()
        let endpoint = URL(string: "https://api.spotify.com/v1/me/playlists")!
        Task.init {
            await sendItemsToSubjectFromPagedEndpoint(
                type: WebAPISimplifiedPlaylistObject.self,
                endpoint: endpoint,
                subject: subject
            )
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func sendItemsToSubjectFromPagedEndpoint<T: Decodable>(type: T.Type, endpoint: URL, subject: PassthroughSubject<[T], WebAPIError>) async {
        var url: URL? = endpoint
        while let u = url {
            var req = URLRequest(url: u)
            req = await addAuthorizationHeader(request: &req)
            
            do {
                let (data, _) = try await URLSession.shared.data(for: req)
                let pager = try decoder.decode(WebAPIPagingObject<T>.self, from: data)
                subject.send(pager.items)
                
                // set next url
                if let nextURLString = pager.next {
                    url = URL(string: nextURLString)
                } else {
                    url = nil
                    subject.send(completion: .finished)
                }
            } catch {
                // TODO: handle errors 
                subject.send(completion: .failure(.unknown))
            }
        }
    }
    
    func getPersonalizedRecommendations() async -> Result<RecommendationsResponse, WebAPIError> {
        // get the current date
        let date = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        
        var comps = URLComponents(string: "https://api.spotify.com/v1/views/personalized-recommendations")!
        comps.queryItems = [
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

        var req = URLRequest(url: comps.url!)
        req.httpMethod = "GET"
        req = await addAuthorizationHeader(request: &req)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let recommendations = try decoder.decode(RecommendationsResponse.self, from: data)
            return .success(recommendations)
        } catch {
            print(error)
            return .failure(.unknown)
        }
    }
    
    private func addAuthorizationHeader(request: inout URLRequest) async -> URLRequest {
        let result = await playerCore.token()
        if case let .success(tokenObj) = result {
            print(tokenObj.tokenType)
            request.setValue("Bearer \(tokenObj.accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            
            // TODO: handle errors here
        }
        
        return request
    }
}
