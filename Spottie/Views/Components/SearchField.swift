//
//  SearchField.swift
//  Spottie
//
//  Created by Lee Jun Kit on 19/6/21.
//

import SwiftUI

// https://stackoverflow.com/questions/64376948/swiftui-how-to-use-nssearchtoolbaritem-on-macos-11
struct SearchField: NSViewRepresentable {
    class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: SearchField

        init(_ parent: SearchField) {
            self.parent = parent
        }

        func controlTextDidChange(_ notification: Notification) {
            guard let searchField = notification.object as? NSSearchField else {
                print("Unexpected control in update notification")
                return
            }
            self.parent.search = searchField.stringValue
        }

    }

    @Binding var search: String

    func makeNSView(context: Context) -> NSSearchField {
        NSSearchField(frame: .zero)
    }

    func updateNSView(_ searchField: NSSearchField, context: Context) {
        searchField.stringValue = search
        searchField.delegate = context.coordinator
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

}
