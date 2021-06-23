//
//  WebAPIPagingObject.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/6/21.
//

import Foundation

struct WebAPIPagingObject<T: Decodable>: Decodable {
    let href: String
    let items: [T]
    let limit: Int
    let offset: Int
    let total: Int
    let next: String?
    let previous: String?
}
