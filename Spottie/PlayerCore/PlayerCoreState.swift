//
//  PlayerCoreState.swift
//  PlayerCoreState
//
//  Created by Lee Jun Kit on 24/8/21.
//

import Foundation

struct PlayerCoreState: Decodable {
    struct Player: Decodable {
        enum PlayState: String, Decodable {
            case playing, paused, stopped
        }
        
        let state: PlayState
        let since: Date?
        let elapsed: Double?
        let trackId: String?
    }
    
    struct Queue: Decodable {
        let currentIndex: Int?
    }
    
    let player: Player
    let queue: Queue
}
