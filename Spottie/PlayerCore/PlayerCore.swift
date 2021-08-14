//
//  PlayerCore.swift
//  Spottie
//
//  Created by Lee Jun Kit on 14/8/21.
//

import Foundation

class PlayerCore {
    func run() {
        let t = Thread.init {
            /*
            librespot_init(f.toOpaque()) { user_data, ptr, len  in
                if let pointer = ptr {
                    let data = Data(bytes: pointer, count: Int(len))
                    do {
                        let ff: Foo = Unmanaged.fromOpaque(user_data!).takeUnretainedValue();
                        let json = try ff.rawDecode(data)
                        print(json)
                    } catch {
                        print("json error: \(error.localizedDescription)")
                    }
                }
            }
             */
        }
        t.name = "AnvilRust"
        t.start()
    }
}
