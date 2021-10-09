//
//  TokenObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/6/21.
//

import Foundation

struct TokenObject: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let scope: [String]
    
    var authHeader: String {
        get {
            return "\(tokenType) \(accessToken)"
        }
    }
}
