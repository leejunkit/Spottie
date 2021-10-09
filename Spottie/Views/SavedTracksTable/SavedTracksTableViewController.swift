//
//  LikedSongsTableViewController.swift
//  LikedSongsTableViewController
//
//  Created by Lee Jun Kit on 22/8/21.
//

import Cocoa

class SavedTracksTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var data: [WebAPISavedTrackObject] = []
    var currentTrackId: String?
    weak var delegate: SavedTracksTable.Coordinator?
    
    var initialized = false
    let scrollView = NSScrollView()
    let tableView = NSTableView()
    let relativeDateFormatter = RelativeDateTimeFormatter()
    
    override func loadView() {
        self.view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayout() {
        if !initialized {
            initialized = true
            setupView()
            setupTableView()
        } else {
            tableView.tableColumns.forEach { tableColumn in
                if tableColumn.identifier.rawValue == "Title" {
                    tableColumn.width = Double(self.view.frame.width) * 0.3
                } else if tableColumn.identifier.rawValue == "Artist" {
                    tableColumn.width = Double(self.view.frame.width) * 0.2
                } else if tableColumn.identifier.rawValue == "Album" {
                    tableColumn.width = Double(self.view.frame.width) * 0.2
                } else if tableColumn.identifier.rawValue == "Date Added" {
                    tableColumn.width = Double(self.view.frame.width) * 0.1
                } else if tableColumn.identifier.rawValue == "Duration" {
                    tableColumn.width = Double(self.view.frame.width) * 0.08
                }
            }
        }
    }
    
    func setupView() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupTableView() {
        self.view.addSubview(scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
        tableView.frame = scrollView.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.doubleAction = #selector(handleDoubleClick)
        
        
        let columns = [
            (name: "Title", width: 0.3),
            (name: "Duration", width: 0.08),
            (name: "Artist", width: 0.2),
            (name: "Album", width: 0.2),
            (name: "Date Added", width: 0.1),
        ]
        
        columns.forEach { column in
            let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: column.name))
            col.title = column.name
            col.width = Double(self.view.frame.width) * column.width
            tableView.addTableColumn(col)
        }
        
        scrollView.documentView = tableView
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = true
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let savedTrack = data[row]
        
        let text = NSTextField()
        if let tableColumn = tableColumn {
            if tableColumn.identifier.rawValue == "Title" {
                text.stringValue = savedTrack.track.name
            } else if tableColumn.identifier.rawValue == "Artist" {
                text.stringValue = savedTrack.track.artistString
            } else if tableColumn.identifier.rawValue == "Album" {
                text.stringValue = savedTrack.track.album.name
            } else if tableColumn.identifier.rawValue == "Date Added" {
                let dateAdded = savedTrack.addedAt
                let now = Date()
                text.stringValue = relativeDateFormatter.localizedString(for: dateAdded, relativeTo: now)
            } else if tableColumn.identifier.rawValue == "Duration" {
                text.stringValue = savedTrack.track.durationString
            }
        }
        
        let cell = NSTableCellView()
        cell.addSubview(text)
        text.drawsBackground = false
        text.isBordered = false
        text.isEditable = false
        text.isSelectable = false
        text.maximumNumberOfLines = 1
        text.translatesAutoresizingMaskIntoConstraints = false
        text.lineBreakMode = .byTruncatingTail
        
        let fd = NSFontDescriptor.preferredFontDescriptor(forTextStyle: .body, options: [:])
        if (savedTrack.track.id == currentTrackId) {
            let boldFd = fd.withSymbolicTraits(.bold)
            text.font = NSFont(descriptor: boldFd, size: fd.pointSize)
            text.textColor = NSColor.systemGreen
        } else {
            text.font = NSFont(descriptor: fd, size: fd.pointSize)
            text.textColor = NSColor.labelColor
        }
        
        NSLayoutConstraint.activate([
            text.leftAnchor.constraint(equalTo: cell.leftAnchor),
            text.rightAnchor.constraint(equalTo: cell.rightAnchor),
            text.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
        ])
        return cell
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = NSTableRowView()
        return rowView
    }
    
    func refresh(savedTracks: [WebAPISavedTrackObject], currentTrackId: String?) {
        self.data = savedTracks
        self.currentTrackId = currentTrackId
        
        let selectedRowIndexes = self.tableView.selectedRowIndexes
        self.tableView.reloadData()
        self.tableView.selectRowIndexes(selectedRowIndexes, byExtendingSelection: false)
    }
    
    @objc func handleDoubleClick() {
        let clickedRow = tableView.clickedRow
        if clickedRow >= 0 {
            if let delegate = self.delegate {
                delegate.onRowDoubleClicked(clickedRow)
            }
        }
    }
}
