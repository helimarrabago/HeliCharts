//
//  AlbumRepository.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/20/25.
//

import Foundation

enum AlbumRepository {
    static var albums: [AlbumKey: Album] = [:]
}

struct AlbumKey: Hashable {
    let name: String
    let artist: String
}
