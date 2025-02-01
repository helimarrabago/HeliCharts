//
//  AlbumResponse.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/20/25.
//

import Foundation

struct AlbumResponse: Decodable {
    let album: Metadata

    struct Metadata: Decodable {
        let mbid: String
        let name: String
        let artist: String
        let tracks: TrackMetadata

        struct TrackMetadata: Decodable {
            let track: [Track]

            struct Track: Decodable {
                let name: String
            }
        }
    }
}
