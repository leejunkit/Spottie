//
//  HTTPClient.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//  https://www.vadimbulavin.com/modern-networking-in-swift-5-with-urlsession-combine-framework-and-codable/

import Foundation
import Combine

struct HTTPClient {
    enum APIError: Error {
        case unknown
        case contentTypeError
    }
    
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                if T.self == Nothing.self {
                    return Response(value: Nothing() as! T, response: result.response)
                }
                
                // check for empty body
                let response = result.response as! HTTPURLResponse
                if response.statusCode == 204 {
                    throw APIError.contentTypeError
                }
                
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func runWithoutDecoding(_ request: URLRequest) -> AnyPublisher<Never, URLError> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .ignoreOutput()
            .eraseToAnyPublisher()
    }
}
