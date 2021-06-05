//
//  Search.swift
//  Spottie
//
//  Created by Lee Jun Kit on 20/5/21.
//

import SwiftUI

struct Search: View {
    let rows: [GridItem] =
            Array(repeating: .init(.fixed(20)), count: 2)
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows, alignment: .top) {
                ForEach((0...79), id: \.self) {
                    let codepoint = $0 + 0x1f600
                    let codepointString = String(format: "%02X", codepoint)
                    Text("\(codepointString)")
                        .font(.footnote)
                    let emoji = String(Character(UnicodeScalar(codepoint)!))
                    Text("\(emoji)")
                        .font(.largeTitle)
                }
            }
        }
    }
}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        Search()
    }
}
