//
//  DBService.swift
//  DBService
//
//  Created by Lee Jun Kit on 25/8/21.
//

import Foundation
import CoreData

struct DBService {
    let container: NSPersistentContainer
    init() {
        container = NSPersistentContainer(name: "v1")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Fatal: Cannot load persistent stores: \(error)")
            }
        }
    }
}
