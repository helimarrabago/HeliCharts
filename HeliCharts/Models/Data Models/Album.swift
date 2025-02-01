//
//  Album.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/20/25.
//

import Foundation

struct Album {
    let id: String
    let name: String
    let artist: String
    let tracks: [Track]

    init(id: String, name: String, artist: String, tracks: [Track]) {
        self.id = id
        self.name = name
        self.artist = artist
        self.tracks = tracks
    }

    init(response: AlbumResponse.Metadata) {
        self.id = response.mbid
        self.name = response.name
        self.artist = response.artist
        self.tracks = response.tracks.track.map { Track(response: $0) }
    }
}
