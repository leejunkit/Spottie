//
//  LikedSongsTable.swift
//  LikedSongsTable
//
//  Created by Lee Jun Kit on 22/8/21.
//

import Foundation
import AppKit
import SwiftUI

struct SavedTracksTable: NSViewControllerRepresentable {
    var currentTrackId: String?
    var data: [WebAPISavedTrackObject]
    var onRowDoubleClicked: (Int) -> Void
    
    typealias NSViewControllerType = SavedTracksTableViewController
    func makeNSViewController(context: Context) -> SavedTracksTableViewController {
        let controller = SavedTracksTableViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateNSViewController(_ nsViewController: SavedTracksTableViewController, context: Context) {
        nsViewController.refresh(savedTracks: data, currentTrackId: currentTrackId)
    }
    
    func makeCoordinator() -> SavedTracksTable.Coordinator {
        return Coordinator(self)
    }
}

extension SavedTracksTable {
    class Coordinator: NSObject {
        var parent: SavedTracksTable
        init(_ parent: SavedTracksTable) {
            self.parent = parent
        }
        
        func onRowDoubleClicked(_ row: Int) {
            self.parent.onRowDoubleClicked(row)
        }
    }
}
