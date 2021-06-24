//
//  WebAPIImageObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 24/5/21.
//

import Foundation

struct WebAPIImageObject: Decodable {
    enum ImageSize {
        case small, medium, large
    }
    
    let url: String
    let width: Int?
    let height: Int?
}
