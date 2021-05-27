//
//  HTTPClient.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//  https://www.vadimbulavin.com/modern-networking-in-swift-5-with-urlsession-combine-framework-and-codable/

import Foundation
import Combine

struct HTTPClient {
    struct Response<T> {
        let value: T?
        let response: URLResponse
    }
    
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                let response = result.response as! HTTPURLResponse
                let contentType = response.allHeaderFields["Content-Type"] as? String
                print(response.allHeaderFields)
                
                if let contentType = contentType {
                    if contentType.contains("application/json") {
                        let value = try decoder.decode(T.self, from: result.data)
                        return Response(value: value, response: result.response)
                    }
                }

                return Response(value: nil, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
